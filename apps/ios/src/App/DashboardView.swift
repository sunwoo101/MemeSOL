import SwiftUI

struct Token: Identifiable {
    let id = UUID()
    let name: String
    let symbol: String
    let pricePerToken: String
    let balance: String
    let percentChange: String
    let positive: Bool
    let icon: String
    let color: Color
}

struct DashboardView: View {
    @State var totalBalance: Double = 12345.67
    @State var totalGainLoss: Double = 234.56
    @State var totalGainLossPercent: Double = -1.94
    
    @State var tokens: [Token] = [
        Token(name: "Ethereum", symbol: "ETH",  pricePerToken: "$3,241.50",  balance: "$4,862.25",  percentChange: "+2.4%",  positive: true,  icon: "diamond.fill",           color: .blue),
        Token(name: "Bitcoin",  symbol: "BTC",  pricePerToken: "$98,430.00", balance: "$2,952.90",  percentChange: "+1.1%",  positive: true,  icon: "bitcoinsign.circle.fill", color: .orange),
        Token(name: "Solana",   symbol: "SOL",  pricePerToken: "$142.30",    balance: "$1,423.00",  percentChange: "-3.8%",  positive: false, icon: "s.circle.fill",           color: .purple),
        Token(name: "USD Coin", symbol: "USDC", pricePerToken: "$1.00",      balance: "$2,100.00",  percentChange: "0.0%",   positive: true,  icon: "dollarsign.circle.fill",   color: .blue),
        Token(name: "Chainlink",symbol: "LINK", pricePerToken: "$13.75",     balance: "$1,007.52",  percentChange: "-1.2%",  positive: false, icon: "link.circle.fill",         color: .cyan),
    ]
    
    private var formattedBalance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
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
                    TokenRow(
                        name: token.name, symbol: token.symbol,
                        price: token.pricePerToken,
                        balance: token.balance,
                        change: token.percentChange,
                        positive: token.positive,
                        icon: token.icon, color: token.color
                    )
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

private struct ActionButton: View {
    let icon: String
    let label: String

    var body: some View {
        Button {} label: {
            VStack(spacing: AppLayout.actionButtonContentSpacing) {
                Image(systemName: icon)
                    .font(.system(size: AppLayout.actionButtonIconSize))
                    .foregroundColor(.white)
                Text(label)
                    .font(.caption)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppLayout.actionButtonVerticalPadding)
            .background(AppColors.charcoalColor)
            .cornerRadius(AppLayout.cornerRadius)
        }
    }
}

private struct TokenRow: View {
    let name: String
    let symbol: String
    let price: String
    let balance: String
    let change: String
    let positive: Bool
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: AppLayout.tokenRowIconSpacing) {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: AppLayout.tokenIconSize, height: AppLayout.tokenIconSize)
                .foregroundColor(color)

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

#Preview {
    DashboardView()
}
