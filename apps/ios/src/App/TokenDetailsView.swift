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
            
            VStack (spacing: 20) {
                Text("Token Details")
                    .font(.title2.bold())
                    .foregroundColor(AppColors.goldColor)
                    .padding(.top, 10)
                
                Circle()
                    .frame(width: 120, height: 120)
                    .padding(.top, 10)
                    .foregroundColor(.blue)
                
                
                VStack {
                    Text("Bitcoin (BTC)")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                    Text("$173.21")
                        .foregroundColor(.white)
                }
                
                VStack {
                    Text("Your Balance")
                    Text("2.18 SOL")
                }
                .foregroundColor(.white)
                
                HStack {
                    Button("Add to Wallet") {
                    }
                    
                    Spacer()
                    
                    Button("♡") {
                    }
                }
                .padding()
                
                Divider()
                    .background(.white)
                    .padding(.horizontal)
                
                Text("Token Information")
                    .foregroundColor(.white)
                    .font(.title3.bold())
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Supply")
                        .foregroundColor(AppColors.secondaryTextColor)

                    Text("1,2028,12830")
                        .foregroundColor(.white)
                        .font(.headline)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(AppColors.charcoalColor)
                .cornerRadius(20)
                
                VStack {
                    Text("Mint Address") //probs not even necessary to show user ?
                    Text("2839x...2u39h9")
                }
                .foregroundColor(.white)

                Divider()
                    .background(.white)
                    .padding(.horizontal)
                
                Text("Recent Transactions")
                    .foregroundColor(.white)
                    .font(.title3.bold())
                
                VStack {
                    Text("Sent 0.5 SOL")
                    Text("Received 0.5 SOL")
                }
                .foregroundColor(.white)
            
                Spacer()
            }
            
        }
    }
}

#Preview {
    TokenDetailsView()
}
