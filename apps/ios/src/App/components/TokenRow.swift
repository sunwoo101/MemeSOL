//
//  TokenRow.swift
//  App
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
        HStack(spacing: AppLayout.tokenRowIconSpacing) {
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
            .frame(width: AppLayout.tokenIconSize, height: AppLayout.tokenIconSize)
            
            VStack(alignment: .leading, spacing: AppLayout.tokenTextStackSpacing) {
                Text(name)
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                Text(symbol)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: AppLayout.tokenTextStackSpacing) {
                Text(balance)
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                HStack(spacing: AppLayout.tokenPriceStackSpacing) {
                    Text(price)
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(change)
                        .font(.caption)
                        .foregroundColor(positive ? .green : .red)
                }
            }
        }
        .padding(.vertical, AppLayout.tokenRowVerticalPadding)
    }
}
