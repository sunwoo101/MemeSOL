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
            AppColors.blackColor.ignoresSafeArea()
            
            VStack (spacing: 20) {
                Text("Send")
                    .font(.title2.bold())
                    .foregroundColor(AppColors.goldColor)
                    .padding(.top, 10)
                
                //recipient address input & scanner
                VStack (alignment: .leading, spacing: 20) {
                    Text("Recipient Address")
                        .foregroundColor(.white)
                        .font(.headline)
                    
                    HStack {
                        TextField("",
                                  text: $address,
                                  prompt: Text("Enter or scan address").foregroundColor(AppColors.secondaryTextColor),
                                    axis: .vertical)
                        .foregroundColor(.white)
                    
                        Spacer()
                        
                        Divider()
                                .frame(height: 45)
                                .background(Color.white.opacity(0.9))
                        
                        Button (action: {
                            showingScanner = true
                        }) {
                            VStack(spacing: 5) {
                                Image(systemName: "qrcode.viewfinder")
                                Text("Scan")
                                    .font(.system(size:12))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 5)
                        }
                    }
                    .padding()
                    .background(AppColors.charcoalColor)
                    .cornerRadius(SharedLayout.cornerRadius)
                    
                    //token selector
                    VStack (alignment: .leading, spacing: 10) {
                        Text("Token")
                            .foregroundColor(.white)
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
                                    .foregroundColor(selectedToken == nil ? AppColors.secondaryTextColor : .white)
                                
                                Spacer ()
                                
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .padding()
                            .background(AppColors.charcoalColor)
                            .cornerRadius(SharedLayout.cornerRadius)
                        }
                    }
                    
                    //amount input
                    VStack (alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Amount")
                                .foregroundColor(.white)
                                .font(.headline)
                            
                            Spacer()
                            
                            Text("Balance: \(selectedToken?.balance ?? 0, specifier: "%.2f")")
                                .foregroundColor(AppColors.secondaryTextColor)
                                .font(.subheadline)
                        }
                        
                        HStack {
                                TextField(
                                    "",
                                    text: $amount,
                                    prompt: Text("0.00").foregroundColor(AppColors.secondaryTextColor)
                                )
                                .keyboardType(.decimalPad)
                                .font(.system(size: 30, weight: .semibold))
                                .foregroundColor(.white)
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
                                    .foregroundColor(AppColors.secondaryTextColor)
                                    .font(.headline)
                            }
                            .padding()
                            .background(AppColors.charcoalColor)
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
                        .background(isSendDisabled ? AppColors.charcoalColor : AppColors.goldColor)
                        .foregroundColor(isSendDisabled ? AppColors.secondaryTextColor : .black)
                        .cornerRadius(SharedLayout.cornerRadius)
                }
                .disabled(isSendDisabled)
                
                Spacer()
                
            }
            .padding(.horizontal, 10)
            
        }
        .task {
            await viewModel.loadTokens()
        }
        
        //confirm modal
        .sheet(isPresented: $showingConfirmModal) {
                
                VStack (spacing: 24) {
                    Text("Confirm Transaction")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        VStack (alignment: .leading, spacing: 4) {
                            Text("Recipient")
                                .foregroundColor(.white)
                            
                            Text(address)
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Token")
                                .foregroundColor(.white)
                            Text(selectedToken?.symbol ?? "")
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Amount")
                                .foregroundColor(.white)
                            
                            Text("\(amount) \(selectedToken?.symbol ?? "")")
                                .font(.title3.bold())
                                .foregroundColor(.white)
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
                                .background(AppColors.charcoalColor)
                                .foregroundColor(.white)
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
                                .background(viewModel.isSending ? AppColors.charcoalColor : AppColors.goldColor)
                                .foregroundColor(viewModel.isSending ? AppColors.secondaryTextColor : .black)
                                .cornerRadius(SharedLayout.cornerRadius)
                        }
                        .disabled(viewModel.isSending)
                    }
                    if !viewModel.sendError.isEmpty {
                        Text(viewModel.sendError)
                            .foregroundColor(.red)
                    }
                }
                .padding()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .presentationBackground(AppColors.blackColor)
                .onDisappear {
                    viewModel.sendError = ""
                }
        }
        
        //qr scanner sheet
        .sheet(isPresented: $showingScanner) {
            CodeScannerView(codeTypes: [.qr], completion: {result in
                if case let .success(code) = result {
                    address = code.string
                    self.showingScanner = false
                }})
        }
    }
}

#Preview {
    SendView()
}
