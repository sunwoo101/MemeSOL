//
//  BuyMenuView.swift
//  App
//
//  Created by Gurpreet on 9/5/2026.
//

import SwiftUI

struct BuyMenuView: View {
    @StateObject private var viewModel = BuyViewModel()

    
    var body: some View {
        ZStack {
            AppColors.blackColor.ignoresSafeArea()
            
            ScrollView {
                VStack {
                    Text("Buy Tokens")
                        .foregroundColor(AppColors.goldColor)
                        .font(.title3.bold())
                    
                    HStack {
                        TextField("",
                                  text: $viewModel.searchText,
                                  prompt: Text("Enter token name or symbol").foregroundColor(AppColors.secondaryTextColor))
                        .foregroundColor(.white)
                        .autocorrectionDisabled()
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 15)
                    .background(AppColors.charcoalColor)
                    .cornerRadius(SharedLayout.cornerRadius)
                    
                    ForEach(viewModel.filteredTokens, id: \.id) { token in
                        NavigationLink {
                            BuyTokenView(token: token)
                        } label: {
                            TokenRow(name: token.name,
                                     symbol: token.symbol,
                                     price: String(format: "$%.2f", token.price),
                                     balance: "",
                                     change: String(format: "%.2f%%", token.gainsPercent),
                                     positive: token.gainsPercent >= 0,
                                     iconUrl: token.imgUrl,
                                     color: .blue
                            )
                        }
                
                        Divider()
                            .background(Color.gray.opacity(0.3))
                            .padding(.leading, 20)
                    }
                }
                .padding()
            }
        }
        .task {
            await viewModel.loadTokens()
        }
    }
}

#Preview {
    BuyMenuView()
}
