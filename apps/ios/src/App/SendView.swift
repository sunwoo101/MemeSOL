//
//  SendView.swift
//  App
//
//  Created by Gurpreet on 6/5/2026.
//

import SwiftUI

struct SendView: View {
    @State var address = ""
    @State var amount = ""
    @State var selectedToken: WalletTokenResponse?
    
    @State var showingConfirmModal: Bool = false
    
    @StateObject var viewModel = SendViewModel()
    
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
                Button("Send") {
                    showingConfirmModal = true
                }
                .disabled(isSendDisabled)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isSendDisabled ? AppColors.charcoalColor : AppColors.goldColor)
                .foregroundColor(isSendDisabled ? AppColors.secondaryTextColor : .black)
                .cornerRadius(SharedLayout.cornerRadius)
                
                Spacer()
                
            }
            .padding(.horizontal, 10)
            
        }
        .task {
            await viewModel.loadTokens()
        }
        
        //confirm modal
        .sheet(isPresented: $showingConfirmModal) {
                VStack (spacing: 20) {
                    Text("Confirm Transaction")
                        .font(.title2.bold())
                }
                VStack(alignment: .leading, spacing: 16) {
                    VStack (alignment: .leading, spacing: 4) {
                        Text("Recipient")
                            .foregroundColor(.secondary)
                        
                        Text(address)
                            .font(.system(.body, design: .monospaced))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Token")
                            .foregroundColor(.secondary)
                        Text(selectedToken?.symbol ?? "")
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Amount")
                            .foregroundColor(.secondary)
                        
                        Text("\(amount) \(selectedToken?.symbol ?? "")")
                            .font(.title3.bold())
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .cornerRadius(20)
                
                HStack(spacing: 16) {
                    Button("Cancel") {
                        showingConfirmModal = false
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.charcoalColor)
                    .foregroundColor(.white)
                    .cornerRadius(SharedLayout.cornerRadius)
                    
                    Button("Send Now") {
                        showingConfirmModal = false
                        //put api call
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.goldColor)
                    .foregroundColor(.black)
                    .cornerRadius(SharedLayout.cornerRadius)
                }
                .padding()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    SendView()
}

//things to do:
//scan button should scan address and fill it in the field
//button needs to go when the user taps anywhere on the button not just one specific part
//color of modal (background)
//modal needs to actually send amount
//blur background when in confirm moda
//reintroduce crypto image?
