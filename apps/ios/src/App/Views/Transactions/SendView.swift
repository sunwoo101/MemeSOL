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
    /// When set (e.g. from token transaction history), selects this mint after wallet tokens load.
    var preselectedMintAddress: String? = nil
    
    @State private var address = ""
    @State private var amount = ""
    @State private var selectedToken: WalletTokenResponse?
    
    
    @State private var showingConfirmModal: Bool = false
    @State private var showingScanner: Bool = false
    
    @StateObject private var viewModel = SendViewModel()
    
    //check to ensure the address input is not empty and that the user has enough crypto to make the transaction
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
            
            VStack (spacing: 20) {
                Text("Send")
                    .font(.title2.bold())
                    .foregroundColor(AppColors.accent)
                    .padding(.top, 10)
                
                //recipient address input & scanner
                VStack (alignment: .leading, spacing: 20) {
                    Text("Recipient Address")
                        .foregroundColor(AppColors.ink)
                        .font(.headline)
                    
                    HStack {
                        TextField("",
                                  text: $address,
                                  prompt: Text("Enter or scan address").foregroundColor(AppColors.secondaryText))
                        .foregroundColor(AppColors.ink)
                        .autocorrectionDisabled()
                        
                        Spacer()
                        
                        Divider()
                            .frame(height: 45)
                            .background(AppColors.ink.opacity(0.3))
                        
                        Button (action: {
                            showingScanner = true
                        }) {
                            VStack(spacing: 5) {
                                Image(systemName: "qrcode.viewfinder")
                                Text("Scan")
                                    .font(.system(size:12))
                            }
                            .foregroundColor(AppColors.ink)
                            .padding(.horizontal, 5)
                        }
                    }
                    .padding()
                    .background(AppColors.surface)
                    .cornerRadius(SharedLayout.cornerRadius)
                    
                    //token selector
                    VStack (alignment: .leading, spacing: 10) {
                        Text("Token")
                            .foregroundColor(AppColors.ink)
                            .font(.headline)
                        
                        Menu {
                            ForEach(viewModel.walletTokens, id: \.id) { token in
                                Button {
                                    selectedToken = token
                                } label: {
                                    Text(token.symbol)
                                }
                            }
                        } label: {
                            HStack {
                                Text(selectedToken?.symbol ?? "Select Token")
                                    .foregroundColor(selectedToken == nil ? AppColors.secondaryText : .white)
                                
                                Spacer ()
                                
                                Image(systemName: "chevron.down")
                                    .foregroundColor(AppColors.ink.opacity(0.7))
                            }
                            .padding()
                            .background(AppColors.surface)
                            .cornerRadius(SharedLayout.cornerRadius)
                        }
                    }
                    
                    //amount input
                    VStack (alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Amount")
                                .foregroundColor(AppColors.ink)
                                .font(.headline)
                            
                            Spacer()
                            
                            Text("Balance: \(selectedToken?.balance ?? 0, specifier: "%.2f")")
                                .foregroundColor(AppColors.secondaryText)
                                .font(.subheadline)
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
                            .onChange(of: amount) {
                                let filtered = amount.filter { "0123456789.".contains($0)
                                }
                                
                                let dotCount = filtered.filter { $0 == "."}.count
                                
                                if dotCount > 1 {
                                    if let firstDot = filtered.firstIndex(of: ".") {
                                        var cleaned = filtered
                                        cleaned.remove(at: firstDot)
                                        
                                        amount = cleaned
                                    }
                                } else {
                                    amount = filtered
                                }
                            }
                            
                            Text(selectedToken?.symbol ?? "")
                                .foregroundColor(AppColors.secondaryText)
                                .font(.headline)
                        }
                        .padding()
                        .background(AppColors.surface)
                        .cornerRadius(SharedLayout.cornerRadius)
                    }
                    
                }
                .padding(.bottom, 15)
                
                //send button
                Button {
                    showingConfirmModal = true
                } label: {
                    Text("Send")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isSendDisabled ? AppColors.surface : AppColors.accent)
                        .foregroundColor(isSendDisabled ? AppColors.secondaryText : AppColors.ink)
                        .cornerRadius(SharedLayout.cornerRadius)
                }
                .disabled(isSendDisabled)
                
                Spacer()
                
            }
            .padding(.horizontal, 10)
            
        }
        .task {
            await viewModel.loadTokens()
            if let mint = preselectedMintAddress?.trimmingCharacters(in: .whitespacesAndNewlines),
               !mint.isEmpty,
               let match = viewModel.walletTokens.first(where: { $0.mintAddress == mint }) {
                selectedToken = match
            }
        }
        
        //confirm modal
        .sheet(isPresented: $showingConfirmModal) {
            
            VStack (spacing: 24) {
                Text("Confirm Transaction")
                    .font(.title2.bold())
                    .foregroundColor(AppColors.ink)
                
                
                VStack(alignment: .leading, spacing: 16) {
                    VStack (alignment: .leading, spacing: 4) {
                        Text("Recipient")
                            .foregroundColor(AppColors.ink)
                        
                        Text(address)
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(AppColors.ink)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Token")
                            .foregroundColor(AppColors.ink)
                        Text(selectedToken?.symbol ?? "")
                            .foregroundColor(AppColors.ink)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Amount")
                            .foregroundColor(AppColors.ink)
                        
                        Text("\(amount) \(selectedToken?.symbol ?? "")")
                            .font(.title3.bold())
                            .foregroundColor(AppColors.ink)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .cornerRadius(20)
                
                HStack(spacing: 16) {
                    
                    Button {
                        showingConfirmModal = false
                    } label: {
                        Text("Cancel")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.surface)
                            .foregroundColor(AppColors.ink)
                            .cornerRadius(SharedLayout.cornerRadius)
                    }
                    
                    Button {
                        guard let token = selectedToken,
                              let decimalAmount = Decimal(string: amount)
                        else { return }
                        
                        Task {
                            await viewModel.sendToken(mintAddress: token.mintAddress, recipientAddress: address, amount: decimalAmount)
                            
                            if viewModel.sendError.isEmpty {
                                amount = ""
                                address = ""
                                selectedToken = nil
                                showingConfirmModal = false
                            }
                            
                        }
                        
                    } label: {
                        Text(viewModel.isSending ? "Sending..." : "Send Now")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.isSending ? AppColors.surface : AppColors.accent)
                            .foregroundColor(viewModel.isSending ? AppColors.secondaryText : AppColors.ink)
                            .cornerRadius(SharedLayout.cornerRadius)
                    }
                    .disabled(viewModel.isSending)
                }
                if !viewModel.sendError.isEmpty {
                    Text(viewModel.sendError)
                        .foregroundColor(AppColors.error)
                }
            }
            .padding()
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
            .presentationBackground(AppColors.canvas)
            .onDisappear {
                viewModel.sendError = ""
            }
        }
        
        //qr scanner sheet
        .sheet(isPresented: $showingScanner) {
            ZStack {
                AppColors.canvas.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Scan QR Code")
                        .font(.title2.bold())
                        .foregroundColor(AppColors.ink)
                    
                    CodeScannerView(codeTypes: [.qr], completion: { result in
                        if case let .success(code) = result {
                            address = code.string
                            self.showingScanner = false
                        }})
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
