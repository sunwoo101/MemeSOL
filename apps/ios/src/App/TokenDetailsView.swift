//
//  TokenDetailsView.swift
//  App
//
//  Created by Gurpreet on 8/5/2026.
//

import SwiftUI

struct TokenDetailsView: View {
    let token: TokenListResponse
    
    
    var body: some View {
        ZStack {
            AppColors.blackColor.ignoresSafeArea()
            
            ScrollView {
                VStack (spacing: 24) {
                    //header
                    VStack (spacing: 16) {
                        Circle()
                            .frame(width: 120, height: 120)
                            .foregroundColor(.blue)
                        
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
                        
                        Text("2.18 BTC")
                            .font(.title.bold())
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.charcoalColor)
                    .cornerRadius(20)
                    
                    //add to wallet + favourite
                    HStack (spacing: 16) {
                        Button("Add to Wallet") {
                            
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.goldColor)
                        .foregroundColor(.black)
                        .cornerRadius(16)
                        
                        Button {
                            //function
                        } label: {
                            Image(systemName: "heart")
                        }
                        .frame(width: 60, height: 55)
                        .background(AppColors.charcoalColor)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                    }
                    
                    //transactions
                    VStack (alignment: .leading, spacing: 20) {
                        Text("Recent Transactions")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        transactionRow(type: "Received",
                                       amount: "+0.52 BTC",
                                       date: "Today • 2:31 PM",
                                       isIncoming: true)
                        
                        Divider()
                            .background(Color.white.opacity(0.2))
                        
                        transactionRow(type: "Sent",
                                       amount: "-0.20 BTC",
                                       date: "Yesterday • 11:08 AM",
                                       isIncoming: false)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(AppColors.charcoalColor)
                    .cornerRadius(20)
                }
                .padding()
            }
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
                .foregroundColor(amount.starts(with: "+")
                                 ? .green
                                 : .white)
                .font(.headline)
        }
    }
}

#Preview {
    TokenDetailsView(token: TokenListResponse(id: "1", mintAddress: "ahifh1i1fiwq13", name: "Bitcoin", symbol: "BTC", imgUrl: "", price: 121.1, gainsPercent: 2.4))
}
