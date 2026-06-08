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
            CachedAsyncImage(url: URL(string: iconUrl)) { phase in
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
                    .foregroundColor(AppColors.ink)
                Text(symbol)
                    .font(.caption)
                    .foregroundColor(AppColors.secondaryText)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: TokenLayout.textStackSpacing) {
                Text(balance)
                    .font(.subheadline.bold())
                    .foregroundColor(AppColors.ink)
                HStack(spacing: TokenLayout.priceStackSpacing) {
                    Text(price)
                        .font(.caption)
                        .foregroundColor(AppColors.secondaryText)
                    Text(change)
                        .font(.caption)
                        .foregroundColor(positive ? AppColors.success : AppColors.error)
                }
            }
        }
        .padding(.vertical, TokenLayout.rowVerticalPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }
}
