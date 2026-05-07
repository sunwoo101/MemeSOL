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
    @StateObject var viewModel = SendViewModel()
    
    
    var body: some View {
        ZStack {
            AppColors.blackColor.ignoresSafeArea()
            
            VStack (spacing: 20) {
                Text("Send")
                    .font(.title2.bold())
                    .foregroundColor(AppColors.goldColor)
                    .padding(.top, 10)
                
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
                
                
                Button("Send") {
                    // show confirm modal
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppColors.goldColor)
                .foregroundColor(.black)
                .cornerRadius(SharedLayout.cornerRadius)
                
                Spacer()
                
            }
            .padding(.horizontal, 10)
            
        }
        .task {
            await viewModel.loadTokens()

        }
    }
}

func tokenIcon(for token: String) -> String {
    switch token {
    case "SOL":
        return "circle.hexagongrid.fill"
    case "USDC":
        return "dollarsign.circle.fill"
    default:
        return "questionmark.circle"
    }
}


#Preview {
    SendView()
}

//things to do
//scan button should scan address and fill it in the field
//send with confirmation modal
//make sure that the user can only put numbers in amount field and it auto formats
