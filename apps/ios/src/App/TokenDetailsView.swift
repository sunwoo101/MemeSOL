//
//  TokenDetailsView.swift
//  App
//
//  Created by Gurpreet on 8/5/2026.
//

import SwiftUI

struct TokenDetailsView: View {
    //let token: TokenListResponse
    
    
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
                            Text("Bitcoin")
                                .font(.title.bold())
                                .foregroundColor(.white)
                            
                            Text("BTC")
                                .foregroundColor(AppColors.secondaryTextColor)
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
                    
                    //token info
                    VStack (alignment: .leading, spacing: 20) {
                        Text("Token Information")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        informationRow(title: "Supply", value: "1,202,191")
                        
                        informationRow(title: "Price", value: "$281.19")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(AppColors.charcoalColor)
                    .cornerRadius(20)
                    
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
    
    //view for the rows in the token information section
    func informationRow (title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundColor(AppColors.secondaryTextColor)
            
            Spacer()
            
            Text(value)
                .foregroundColor(.white)
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
    TokenDetailsView()
}
