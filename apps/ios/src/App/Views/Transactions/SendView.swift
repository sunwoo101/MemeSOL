//
//  SendView.swift
//  App
//
//  Created by Gurpreet on 6/5/2026.
//

import SwiftUI
import CodeScanner
internal import AVFoundation

struct SendView: View {
    var preselectedMintAddress: String? = nil

    @State private var address = ""
    @State private var amount = ""
    @State private var selectedToken: WalletTokenResponse?
    @State private var showingConfirmModal = false
    @State private var showingScanner = false

    @StateObject private var viewModel = SendViewModel()

    private var isSendDisabled: Bool {
        address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        !viewModel.isTransactionValid(
            balance: selectedToken?.balance,
            amount: Decimal(string: amount)
        )
    }

    var body: some View {
        ZStack {
            AppColors.canvas.ignoresSafeArea()

            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Recipient Address")
                        .font(.headline)
                        .foregroundColor(AppColors.ink)

                    HStack {
                        TextField(
                            "",
                            text: $address,
                            prompt: Text("Enter or scan address").foregroundColor(AppColors.secondaryText)
                        )
                        .foregroundColor(AppColors.ink)
                        .autocorrectionDisabled()

                        Spacer()

                        Divider()
                            .frame(height: 45)
                            .background(AppColors.ink.opacity(0.3))

                        Button {
                            showingScanner = true
                        } label: {
                            VStack(spacing: 5) {
                                Image(systemName: "qrcode.viewfinder")
                                Text("Scan")
                                    .font(.system(size: 12))
                            }
                            .foregroundColor(AppColors.ink)
                            .padding(.horizontal, 5)
                        }
                    }
                    .padding()
                    .background(AppColors.surface)
                    .cornerRadius(SharedLayout.cornerRadius)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Token")
                            .font(.headline)
                            .foregroundColor(AppColors.ink)

                        Menu {
                            ForEach(viewModel.walletTokens, id: \.id) { token in
                                Button { selectedToken = token } label: {
                                    Text(token.symbol)
                                }
                            }
                        } label: {
                            HStack {
                                Text(selectedToken?.symbol ?? "Select Token")
                                    .foregroundColor(selectedToken == nil ? AppColors.secondaryText : AppColors.ink)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(AppColors.ink.opacity(0.7))
                            }
                            .padding()
                            .background(AppColors.surface)
                            .cornerRadius(SharedLayout.cornerRadius)
                        }
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Amount")
                                .font(.headline)
                                .foregroundColor(AppColors.ink)
                            Spacer()
                            Text("Balance: \(selectedToken?.balance ?? 0, specifier: "%.2f")")
                                .font(.subheadline)
                                .foregroundColor(AppColors.secondaryText)
                        }

                        HStack {
                            TextField(
                                "",
                                text: $amount,
                                prompt: Text("0.00").foregroundColor(AppColors.secondaryText)
                            )
                            .keyboardType(.decimalPad)
                            .font(.system(size: 30, weight: .semibold))
                            .foregroundColor(AppColors.ink)
                            .onChange(of: amount) { _, new in
                                let filtered = new.filter { "0123456789.".contains($0) }
                                let dotCount = filtered.filter { $0 == "." }.count
                                if dotCount > 1, let firstDot = filtered.firstIndex(of: ".") {
                                    var cleaned = filtered
                                    cleaned.remove(at: firstDot)
                                    amount = cleaned
                                } else {
                                    amount = filtered
                                }
                            }

                            Text(selectedToken?.symbol ?? "")
                                .font(.headline)
                                .foregroundColor(AppColors.secondaryText)
                        }
                        .padding()
                        .background(AppColors.surface)
                        .cornerRadius(SharedLayout.cornerRadius)
                    }
                }

                PrimaryButton(label: "Send", disabled: isSendDisabled) {
                    showingConfirmModal = true
                }

                Spacer()
            }
            .padding(.horizontal, SharedLayout.horizontalPadding)
            .padding(.top, SharedLayout.sectionSpacing)
            .padding(.bottom, SharedLayout.horizontalPadding)
        }
        .navigationTitle("Send")
        .task {
            await viewModel.loadTokens()
            if let mint = preselectedMintAddress?.trimmingCharacters(in: .whitespacesAndNewlines),
               !mint.isEmpty,
               let match = viewModel.walletTokens.first(where: { $0.mintAddress == mint }) {
                selectedToken = match
            }
        }
        .sheet(isPresented: $showingConfirmModal) {
            VStack(spacing: 24) {
                Text("Confirm Transaction")
                    .font(.title2.bold())
                    .foregroundColor(AppColors.ink)

                VStack(alignment: .leading, spacing: 16) {
                    ConfirmDetailRow(label: "Recipient", value: address)
                    ConfirmDetailRow(label: "Token", value: selectedToken?.symbol ?? "")
                    ConfirmDetailRow(label: "Amount", value: "\(amount) \(selectedToken?.symbol ?? "")", prominent: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(AppColors.surface)
                .cornerRadius(SharedLayout.cornerRadius)

                HStack(spacing: 12) {
                    SecondaryButton(label: "Cancel") {
                        showingConfirmModal = false
                    }
                    PrimaryButton(label: viewModel.isSending ? "Sending..." : "Send Now", disabled: viewModel.isSending) {
                        guard let token = selectedToken,
                              let decimalAmount = Decimal(string: amount) else { return }
                        Task {
                            await viewModel.sendToken(mintAddress: token.mintAddress, recipientAddress: address, amount: decimalAmount)
                            if viewModel.sendError.isEmpty {
                                amount = ""
                                address = ""
                                selectedToken = nil
                                showingConfirmModal = false
                            }
                        }
                    }
                }

                if !viewModel.sendError.isEmpty {
                    Text(viewModel.sendError)
                        .font(.footnote)
                        .foregroundColor(AppColors.error)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(SharedLayout.horizontalPadding)
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
            .presentationBackground(AppColors.canvas)
            .onDisappear { viewModel.sendError = "" }
        }
        .sheet(isPresented: $showingScanner) {
            ZStack {
                AppColors.canvas.ignoresSafeArea()
                VStack(spacing: 20) {
                    Text("Scan QR Code")
                        .font(.title2.bold())
                        .foregroundColor(AppColors.ink)
                    CodeScannerView(codeTypes: [.qr]) { result in
                        if case let .success(code) = result {
                            address = code.string
                            showingScanner = false
                        }
                    }
                    .cornerRadius(SharedLayout.cornerRadius)
                    .frame(width: 300, height: 300)
                }
            }
        }
    }
}

#Preview {
    SendView()
}
