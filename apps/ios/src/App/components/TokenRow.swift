//
//  TokenRow.swift
//  Assignment3
//
//  Created by Daniel Liu  on 5/5/2026.
//
import SwiftUI

struct TokenRow: View {
    let name: String
    let symbol: String
    let price: String
    let balance: String
    let change: String
    let positive: Bool
    let iconUrl: String
    let color: Color

    var body: some View {
        HStack(spacing: TokenLayout.rowIconSpacing) {
            AsyncImage(url: URL(string: iconUrl)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                default:
                    Image(systemName: "circle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(color)
                }
            }
            .frame(width: TokenLayout.iconSize, height: TokenLayout.iconSize)

            VStack(alignment: .leading, spacing: TokenLayout.textStackSpacing) {
                Text(name)
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                Text(symbol)
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: TokenLayout.textStackSpacing) {
                Text(balance)
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                HStack(spacing: TokenLayout.priceStackSpacing) {
                    Text(price)
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(change)
                        .font(.caption)
                        .foregroundColor(positive ? .green : .red)
                }
            }
        }
        .padding(.vertical, TokenLayout.rowVerticalPadding)
    }
}
