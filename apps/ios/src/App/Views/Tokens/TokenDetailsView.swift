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
            AppColors.canvas.ignoresSafeArea()
            
            ScrollView {
                VStack (spacing: 24) {

                    //header
                    VStack (spacing: 16) {
                        AsyncImage(url: URL(string: token.imgUrl)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder : {
                            Circle().fill(AppColors.surface)
                        }
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        
                        VStack (spacing: 6) {
                            Text(token.name)
                                .font(.title.bold())
                                .foregroundColor(AppColors.ink)
                            
                            Text(token.symbol)
                                .foregroundColor(AppColors.secondaryText)
                            
                            Text("$\(token.price, specifier: "%.2f")")
                                .font(.title3.bold())
                                .foregroundColor(AppColors.accent)
                            
                        }
                    }
                    
                    //balance
                    VStack (spacing: 8) {
                        Text("Your Balance")
                            .foregroundColor(AppColors.secondaryText)
                        
                        Text("\(viewModel.walletToken?.balance ?? 0, specifier: "%.2f") \(token.symbol)")
                            .font(.title.bold())
                            .foregroundColor(AppColors.ink)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.surface)
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
                                .background(viewModel.isInWallet ? AppColors.error : AppColors.accent)
                                .foregroundColor(AppColors.ink)
                                .cornerRadius(16)
                        }
                        
                        Button {
                            viewModel.toggleFavourite(token.mintAddress)
                        } label: {
                            Image(systemName: viewModel.isFavourite(token.mintAddress) ? "heart.fill" : "heart")
                                .frame(width: 60, height: 55)
                                .background(AppColors.surface)
                                .foregroundColor(viewModel.isFavourite(token.mintAddress) ? AppColors.error : AppColors.ink)
                                .cornerRadius(16)
                        }
                    }
                    
                    //transactions
                    VStack (alignment: .leading, spacing: 20) {
                        Text("Recent Transactions")
                            .font(.headline)
                            .foregroundColor(AppColors.ink)
                        
                        if viewModel.transactions.isEmpty {
                            Text("No transactions yet.")
                                .foregroundColor(AppColors.secondaryText)
                        }
                        
                        else {
                            ForEach(viewModel.transactions, id: \.signature) { transaction in
                                let formattedAmount = (transaction.transactionType == "received" ? "+" : "-") +
                                "\(transaction.amount ?? 0) \(transaction.tokenSymbol)"
                                
                                
                                transactionRow(type: transaction.transactionType?.capitalized ?? "Unknown",
                                               amount: formattedAmount,
                                               date: formattedDate(timestamp: transaction.timestamp),
                                               isIncoming: transaction.transactionType == "received")
                                
                                Divider()
                                    .background(AppColors.secondaryText.opacity(0.2))
                                
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(AppColors.surface)
                    .cornerRadius(20)
                }
                .padding()
            }
        }
        .refreshable {
            await viewModel.loadWalletData(mintAddress: token.mintAddress)
            await viewModel.loadTransactionData(mintAddress: token.mintAddress)
            await viewModel.checkIfInWallet(mintAddress: token.mintAddress)
        }
        .onAppear {
            Task {
                await viewModel.loadWalletData(mintAddress: token.mintAddress)
                await viewModel.loadTransactionData(mintAddress: token.mintAddress)
                await viewModel.checkIfInWallet(mintAddress: token.mintAddress)
            }
        }
    }
    
    //view for the rows in the recent transactions section
    func transactionRow (type: String, amount: String, date: String, isIncoming: Bool) -> some View {
        HStack (spacing: 14) {
            VStack (alignment: .leading, spacing: 4) {
                Text(type)
                    .foregroundColor(AppColors.ink)
                    .font(.headline)
                
                Text(date)
                    .foregroundColor(AppColors.secondaryText)
                    .font(.caption)
            }
            
            Spacer()
            
            Text(amount)
                .foregroundColor(isIncoming ? AppColors.success : AppColors.ink)
                .font(.headline)
        }
    }
    
    func formattedDate(timestamp: String) -> String {
        let inputFormatter = ISO8601DateFormatter()
        
        guard let date = inputFormatter.date(from: timestamp) else {
            return timestamp
        }
                
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMM d - h:mm a"
        return outputFormatter.string(from: date)
    }
}

#Preview {
    TokenDetailsView(token: TokenListResponse(id: "1", mintAddress: "ahifh1i1fiwq13", name: "Bitcoin", symbol: "BTC", imgUrl: "", price: 121.1, gainsPercent: 2.4))
}
