//
//  TokenViewDetails.swift
//  Assignment3
//
//  Created by Daniel Liu  on 5/5/2026.
//

import SwiftUI

struct TokenViewDetails: View {
    let token: Token

    var body: some View {
        ZStack {
            AppColors.blackColor.ignoresSafeArea()

            VStack(spacing: AppLayout.sectionSpacing) {
                AsyncImage(url: URL(string: token.iconUrl)) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFit()
                    default:
                        Image(systemName: "circle.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(token.color)
                    }
                }
                .frame(width: AppLayout.tokenDetailIconSize, height: AppLayout.tokenDetailIconSize)

                VStack(spacing: AppLayout.tokenTextStackSpacing) {
                    Text(token.name)
                        .font(.title.bold())
                        .foregroundColor(.white)
                    Text(token.symbol)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                VStack(spacing: AppLayout.tokenTextStackSpacing) {
                    Text(token.pricePerToken)
                        .font(.system(size: AppLayout.tokenDetailPriceFontSize, weight: .bold))
                        .foregroundColor(.white)
                    Text(token.percentChange)
                        .font(.headline)
                        .foregroundColor(token.positive ? .green : .red)
                }

                VStack(spacing: AppLayout.tokenBalanceSpacing) {
                    Text("Your Balance")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(token.balance)
                        .font(.title2.bold())
                        .foregroundColor(.white)
                }

                Spacer()

                Text("More details coming soon")
                    .font(.caption)
                    .foregroundColor(.gray)

                Spacer()
            }
            .padding(.top, AppLayout.tokenDetailTopPadding)
            .padding(.horizontal, AppLayout.horizontalPadding)
        }
    }
}

#Preview {
    TokenViewDetails(token: Token(
        name: "Bitcoin", symbol: "BTC",
        pricePerToken: "A$98,430.00", balance: "A$2,952.90",
        percentChange: "+1.1%", positive: true,
        iconUrl: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png",
        color: .orange
    ))
}
