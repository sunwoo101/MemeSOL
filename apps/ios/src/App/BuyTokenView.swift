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
    
    @State private var showingConfirmModal: Bool = false
    
    
    var body: some View {
        ZStack {
            AppColors.blackColor.ignoresSafeArea()
            
            ScrollView {
                VStack (spacing: 24) {
                    
                    VStack (spacing: 16) {
                        AsyncImage(url: URL(string: token.imgUrl)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder : {
                            Circle().fill(AppColors.charcoalColor)
                        }
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        
                        VStack (spacing: 6) {
                            Text(token.name)
                                .font(.title.bold())
                                .foregroundColor(.white)
                            
                            Text(token.symbol)
                                .foregroundColor(AppColors.secondaryTextColor)
                            
                            Text("$\(token.price, specifier: "%.2f")")
                                .font(.title3.bold())
                                .foregroundColor(AppColors.goldColor)
                            
                            Text(token.gainsPercent > 0 ? ("+\(token.gainsPercent, specifier: "%.2f")%") : ("\(token.gainsPercent, specifier: "%.2f")%"))
                                .foregroundColor(token.gainsPercent > 0 ? .green : .red)
                        }
                        
                        VStack (spacing: 8) {
                            Text("Your Balance")
                                .foregroundColor(AppColors.secondaryTextColor)
                            
                            Text("\(viewModel.walletToken?.balance ?? 0, specifier: "%.2f") \(token.symbol)")
                                .font(.title.bold())
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.charcoalColor)
                        .cornerRadius(20)
                        
                        
                        VStack (alignment: .leading) {
                            Text("Amount")
                                .foregroundColor(.white)
                                .font(.headline)
                            
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
                                
                                Text(token.symbol)
                                    .foregroundColor(AppColors.secondaryTextColor)
                                    .font(.headline)
                            }
                        }
                        .padding()
                        .background(AppColors.charcoalColor)
                        .cornerRadius(SharedLayout.cornerRadius)
                        
                        Button {
                            showingConfirmModal = true
                        } label: {
                            Text("Buy \(token.symbol)")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(amount.isEmpty ? AppColors.charcoalColor : AppColors.goldColor)
                                .foregroundColor(amount.isEmpty ? AppColors.secondaryTextColor : .black)
                                .cornerRadius(SharedLayout.cornerRadius)
                        }
                        .disabled(amount.isEmpty)
                    }
                }
                .padding()
                
            }
            
        }
        .task {
            await viewModel.loadWalletData(mintAddress: token.mintAddress)
        }
        
        .sheet(isPresented: $showingConfirmModal) {
            VStack(spacing: 24) {

                Text("Confirm Purchase")
                    .font(.title2.bold())
                    .foregroundColor(.white)

                VStack(alignment: .leading, spacing: 16) {

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Token")
                            .foregroundColor(.white)

                        Text("\(token.name) (\(token.symbol))")
                            .foregroundColor(.white)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Amount")
                            .foregroundColor(.white)

                        Text("\(amount) \(token.symbol)")
                            .font(.title3.bold())
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()

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
                        // logic
                    } label: {
                        Text(viewModel.isBuying ? "Purchasing..." : "Purchase")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                viewModel.isBuying
                                ? AppColors.charcoalColor
                                : AppColors.goldColor
                            )
                            .foregroundColor(
                                viewModel.isBuying
                                ? AppColors.secondaryTextColor
                                : .black
                            )
                            .cornerRadius(SharedLayout.cornerRadius)
                    }
                    .disabled(viewModel.isBuying)
                }

                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                }
            }
            .padding()
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
            .presentationBackground(AppColors.blackColor)
        }
            
        }
    
    }



#Preview {
    BuyTokenView(token: TokenListResponse(id: "1", mintAddress: "ahifh1i1fiwq13", name: "Bitcoin", symbol: "BTC", imgUrl: "", price: 121.1, gainsPercent: 2.4))
}

    
//things to do
//if not in wallet, when bought, add to wallet
//balance needs to udpate
//could just exit out of screen to avoid that
