//
//  Dashboard.swift
//  Assignment3
//
//  Created by Daniel Liu on 05/5/2026.
//

import SwiftUI

struct DashboardView: View {
    
    @State var totalBalance: Double = 12345.67
    @State var totalGainLoss: Double = 234.56
    @State var totalGainLossPercent: Double = -1.94
    
    @State var tokens: [Token] = [
        Token(name: "Ethereum", symbol: "ETH",  pricePerToken: "A$3,241.50",  balance: "A$4,862.25",  percentChange: "+2.4%",  positive: true,  iconUrl: "https://assets.coingecko.com/coins/images/279/large/ethereum.png", color: .blue),
        Token(name: "Bitcoin",  symbol: "BTC",  pricePerToken: "$A98,430.00", balance: "A$2,952.90",  percentChange: "+1.1%",  positive: true,  iconUrl: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png", color: .orange),
        Token(name: "Solana",   symbol: "SOL",  pricePerToken: "A$142.30",    balance: "A$1,423.00",  percentChange: "-3.8%",  positive: false, iconUrl: "https://assets.coingecko.com/coins/images/4128/large/solana.png", color: .purple),
        Token(name: "Chainlink",symbol: "LINK", pricePerToken: "A$13.75",     balance: "A$1,007.52",  percentChange: "-1.2%",  positive: false, iconUrl: "https://assets.coingecko.com/coins/images/877/large/chainlink-new-logo.png", color: .cyan),
    ]
    
    private var formattedBalance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "AUD"
        return formatter.string(from: NSNumber(value: totalBalance)) ?? "$0.00"
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: AppLayout.sectionSpacing) {
                totalBalanceView
                actionButtonsRow
                tokensSection
            }
            .padding(.horizontal, AppLayout.horizontalPadding)
            .padding(.top, AppLayout.horizontalPadding)
            .padding(.bottom, AppLayout.horizontalPadding)
        }
        .background(AppColors.blackColor.ignoresSafeArea())
    }
    
    private var totalBalanceView: some View {
        VStack(alignment: .center, spacing: AppLayout.balanceStackSpacing) {
            Text("Total Balance")
                .font(.system(size: AppLayout.labelFontSize, weight: .medium))
                .foregroundColor(AppColors.goldColor)
            Text(formattedBalance)
                .font(.system(size: AppLayout.balanceFontSize, weight: .bold))
                .foregroundColor(.white)
            
            let isGain = totalGainLoss >= 0
            let sign = isGain ? "+" : "-"
            let gainLossColor: Color = isGain ? .green : .red
            Label {
                Text("\(sign)$\(String(format: AppLayout.currencyFormat, abs(totalGainLoss))) (\(sign)\(String(format: AppLayout.currencyFormat, abs(totalGainLossPercent)))%)")
                    .font(.system(size: AppLayout.gainLossFontSize, weight: .medium))
                    .foregroundColor(gainLossColor)
            } icon: {
                Image(systemName: isGain ? "arrow.up.right" : "arrow.down.right")
                    .font(.system(size: AppLayout.gainLossIconSize, weight: .bold))
                    .foregroundColor(gainLossColor)
            }
        }
    }
    
    private var actionButtonsRow: some View {
        HStack(spacing: AppLayout.actionButtonRowSpacing) {
            ActionButton(icon: "arrow.right",     label: "Send")
            ActionButton(icon: "arrow.down.left", label: "Receive")
        }
    }
    
    private var tokensSection: some View {
        VStack(alignment: .leading, spacing: AppLayout.tokenRowSpacing) {
            sectionHeader("Tokens")
            
            VStack(spacing: AppLayout.tokenListSpacing) {
                ForEach(Array(tokens.enumerated()), id: \.element.id) { index, token in
                    Button {
                        print("Tapped on token \(token.name)")
                    } label: {
                        TokenRow(
                            name: token.name, symbol: token.symbol,
                            price: token.pricePerToken,
                            balance: token.balance,
                            change: token.percentChange,
                            positive: token.positive,
                            iconUrl: token.iconUrl, color: token.color
                        )
                    }
                    .buttonStyle(.plain)
                    if index < tokens.count - 1 {
                        Divider()
                            .background(Color.gray.opacity(AppLayout.dividerOpacity))
                            .padding(.leading, AppLayout.dividerLeadingPadding)
                    }
                }
            }
        }
    }
    
    private func sectionHeader(_ title: String) -> some View {
        Button {} label: {
            HStack(spacing: AppLayout.sectionHeaderSpacing) {
                Text(title)
                    .font(.headline.bold())
                    .foregroundColor(.white)
                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    DashboardView()
}
