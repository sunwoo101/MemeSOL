//
//  TokenDetailsView.swift
//  App
//
//  Created by Gurpreet on 8/5/2026.
//

import SwiftUI

struct TokenDetailsView: View {
    let token: TokenListResponse
    
    @StateObject var viewModel = TokenDetailsViewModel()
    
    
    var body: some View {
        ZStack {
            AppColors.blackColor.ignoresSafeArea()
            
            ScrollView {
                VStack (spacing: 24) {
                    //header
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
                            
                        }
                    }
                    
                    //balance
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
                    
                    //add to wallet + favourite
                    HStack (spacing: 16) {
                        Button {
                            Task {
                                if viewModel.isInWallet {
                                    try await APIClient.shared.removeWalletToken(mintAddress: token.mintAddress)
                                } else {
                                    try await APIClient.shared.addWalletToken(mintAddress: token.mintAddress)
                                }
                                
                                await viewModel.checkIfInWallet(mintAddress: token.mintAddress)
                            }
                        } label : {
                            Text(viewModel.isInWallet ? "Remove from Wallet" : "Add to Wallet")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(viewModel.isInWallet ? .red : AppColors.goldColor)
                                .foregroundColor(viewModel.isInWallet ? .white : .black)
                                .cornerRadius(16)
                        }
                        
                        Button {
                            viewModel.toggleFavourite(token.mintAddress)
                        } label: {
                            Image(systemName: viewModel.isFavourite(token.mintAddress) ? "heart.fill" : "heart")
                                .frame(width: 60, height: 55)
                                .background(AppColors.charcoalColor)
                                .foregroundColor(viewModel.isFavourite(token.mintAddress) ? .red : .white)
                                .cornerRadius(16)
                        }
                    }
                    
                    //transactions
                    VStack (alignment: .leading, spacing: 20) {
                        Text("Recent Transactions")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        if viewModel.transactions.isEmpty {
                            Text("No transactions yet.")
                                .foregroundColor(AppColors.secondaryTextColor)
                        }
                        
                        else {
                            ForEach(viewModel.transactions, id: \.signature) { transaction in
                                let formattedAmount = (transaction.transactionType == "receive" ? "+" : "-") +
                                "\(transaction.amount ?? 0) \(transaction.tokenSymbol)"
                                
                                
                                transactionRow(type: transaction.transactionType ?? "Unknown",
                                               amount: formattedAmount,
                                               date: transaction.timestamp,
                                               isIncoming: transaction.transactionType == "receive")
                                
                                Divider()
                                    .background(Color.white.opacity(0.2))
                                
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(AppColors.charcoalColor)
                    .cornerRadius(20)
                }
                .padding()
            }
        }
        .task {
            await viewModel.loadWalletData(mintAddress: token.mintAddress)
            
            await viewModel.loadTransactionData(mintAddress: token.mintAddress)
        }
    }
    
    //view for the rows in the recent transactions section
    func transactionRow (type: String, amount: String, date: String, isIncoming: Bool) -> some View {
        HStack (spacing: 14) {
            VStack (alignment: .leading, spacing: 4) {
                Text(type)
                    .foregroundColor(.white)
                    .font(.headline)
                
                Text(date)
                    .foregroundColor(AppColors.secondaryTextColor)
                    .font(.caption)
            }
            
            Spacer()
            
            Text(amount)
                .foregroundColor(isIncoming ? .green : .white)
                .font(.headline)
        }
    }
}

#Preview {
    TokenDetailsView(token: TokenListResponse(id: "1", mintAddress: "ahifh1i1fiwq13", name: "Bitcoin", symbol: "BTC", imgUrl: "", price: 121.1, gainsPercent: 2.4))
}
