//
//  BuyMenuView.swift
//  App
//
//  Created by Gurpreet on 9/5/2026.
//

import SwiftUI

struct BuyMenuView: View {
    @State private var selectedToken: TokenListResponse?
    
    @StateObject private var viewModel = BuyViewModel()

    
    var body: some View {
        ZStack {
            AppColors.blackColor.ignoresSafeArea()
            
            ScrollView {
                VStack {
                    Text("Buy Tokens")
                        .foregroundColor(AppColors.goldColor)
                        .font(.title3.bold())
                    
                    ForEach(viewModel.tokens, id: \.id) { token in
                        Button {
                            selectedToken = token
                        } label: {
                            TokenRow(name: token.name,
                                     symbol: token.symbol,
                                     price: String(format: "$%.2f", token.price),
                                     balance: "",
                                     change: String(format: "%.2f%%", token.gainsPercent),
                                     positive: token.gainsPercent >= 0,
                                     iconUrl: token.imgUrl,
                                     color: .blue)
                            .buttonStyle(.plain)
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
//        .navigationDestination(item: $selectedToken) { token in
//            BuyTokenView(token: token)
//        }
    }
}

#Preview {
    BuyMenuView()
}
