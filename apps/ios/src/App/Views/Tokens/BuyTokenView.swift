//
//  BuyTokenView.swift
//  App
//
//  Created by Gurpreet on 9/5/2026.
//

import SwiftUI

struct BuyTokenView: View {
    let token: TokenListResponse

    @StateObject private var viewModel = BuyViewModel()
    @State private var amount = ""
    @State private var showingConfirmModal = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            AppColors.canvas.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    TokenHeaderView(token: token)

                    VStack(spacing: 8) {
                        Text("Your Balance")
                            .font(.subheadline)
                            .foregroundColor(AppColors.secondaryText)
                        Text("\(viewModel.walletToken?.balance ?? 0, specifier: "%.2f") \(token.symbol)")
                            .font(.title.bold())
                            .foregroundColor(AppColors.ink)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.surface)
                    .cornerRadius(SharedLayout.cornerRadius)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Amount")
                            .font(.headline)
                            .foregroundColor(AppColors.ink)

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

                            Text(token.symbol)
                                .font(.headline)
                                .foregroundColor(AppColors.secondaryText)
                        }
                        .padding()
                        .background(AppColors.surface)
                        .cornerRadius(SharedLayout.cornerRadius)
                    }

                    PrimaryButton(label: "Buy \(token.symbol)", disabled: amount.isEmpty) {
                        showingConfirmModal = true
                    }
                }
                .padding(SharedLayout.horizontalPadding)
            }
        }
        .navigationTitle(token.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadWalletData(mintAddress: token.mintAddress)
        }
        .sheet(isPresented: $showingConfirmModal) {
            VStack(spacing: 24) {
                Text("Confirm Purchase")
                    .font(.title2.bold())
                    .foregroundColor(AppColors.ink)

                VStack(alignment: .leading, spacing: 16) {
                    ConfirmDetailRow(label: "Token", value: "\(token.name) (\(token.symbol))")
                    ConfirmDetailRow(label: "Amount", value: "\(amount) \(token.symbol)", prominent: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(AppColors.surface)
                .cornerRadius(SharedLayout.cornerRadius)

                HStack(spacing: 12) {
                    SecondaryButton(label: "Cancel") {
                        showingConfirmModal = false
                    }
                    PrimaryButton(label: viewModel.isBuying ? "Purchasing..." : "Purchase", disabled: viewModel.isBuying) {
                        guard let decimalAmount = Decimal(string: amount) else { return }
                        Task {
                            await viewModel.buyToken(mintAddress: token.mintAddress, amount: decimalAmount)
                            if viewModel.errorMessage.isEmpty {
                                amount = ""
                                showingConfirmModal = false
                                dismiss()
                            }
                        }
                    }
                }

                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .font(.footnote)
                        .foregroundColor(AppColors.error)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(SharedLayout.horizontalPadding)
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
            .presentationBackground(AppColors.canvas)
        }
    }
}

#Preview {
    BuyTokenView(token: TokenListResponse(id: "1", mintAddress: "ahifh1i1fiwq13", name: "Bitcoin", symbol: "BTC", imgUrl: "", price: 121.1, gainsPercent: 2.4))
}
