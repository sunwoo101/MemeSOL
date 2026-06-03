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
            AppColors.canvas.ignoresSafeArea()
            
            ScrollView {
                VStack {
                    Text("Buy Tokens")
                        .foregroundColor(AppColors.accent)
                        .font(.title2.bold())
                    
                    HStack {
                        TextField("",
                                  text: $viewModel.searchText,
                                  prompt: Text("Enter token name or symbol").foregroundColor(AppColors.secondaryText))
                        .foregroundColor(AppColors.ink)
                        .autocorrectionDisabled()
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 15)
                    .background(AppColors.surface)
                    .cornerRadius(SharedLayout.cornerRadius)
                    
                    ForEach(viewModel.filteredTokens, id: \.id) { token in
                        NavigationLink {
                            BuyTokenView(token: token)
                        } label: {
                            TokenRow(name: token.name,
                                     symbol: token.symbol,
                                     price: "",
                                     balance: String(format: "$%.2f", token.price),
                                     change: String(format: "%.2f%%", token.gainsPercent),
                                     positive: token.gainsPercent >= 0,
                                     iconUrl: token.imgUrl,
                                     color: AppColors.info
                            )
                        }
                        
                        Divider()
                            .background(AppColors.secondaryText.opacity(0.3))
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
