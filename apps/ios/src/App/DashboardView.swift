//
//  Dashboard.swift
//  Assignment3
//
//  Created by Daniel Liu on 05/5/2026.
//

import SwiftUI

struct DashboardView: View {
    @Environment(AuthSession.self) private var authSession

    @State var totalBalance: Double = 12345.67
    @State var totalGainLoss: Double = 234.56
    @State var totalGainLossPercent: Double = -1.94
    @State private var selectedToken: Token? = nil
    @State private var activeTab: Int = 0

    @State var tokens: [Token] = [
        Token(
            name: "Ethereum", symbol: "ETH", pricePerToken: "A$3,241.50", balance: "A$4,862.25",
            percentChange: "+2.4%", positive: true,
            iconUrl: "https://assets.coingecko.com/coins/images/279/large/ethereum.png",
            color: .blue),
        Token(
            name: "Bitcoin", symbol: "BTC", pricePerToken: "$A98,430.00", balance: "A$2,952.90",
            percentChange: "+1.1%", positive: true,
            iconUrl: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png", color: .orange
        ),
        Token(
            name: "Solana", symbol: "SOL", pricePerToken: "A$142.30", balance: "A$1,423.00",
            percentChange: "-3.8%", positive: false,
            iconUrl: "https://assets.coingecko.com/coins/images/4128/large/solana.png",
            color: .purple),
        Token(
            name: "Chainlink", symbol: "LINK", pricePerToken: "A$13.75", balance: "A$1,007.52",
            percentChange: "-1.2%", positive: false,
            iconUrl: "https://assets.coingecko.com/coins/images/877/large/chainlink-new-logo.png",
            color: .cyan),
    ]

    private var formattedBalance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "AUD"
        return formatter.string(from: NSNumber(value: totalBalance)) ?? "$0.00"
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(authSession.walletPublicKey)
                    .font(.caption2.monospaced())
                    .foregroundColor(AppColors.secondaryTextColor)
                    .lineLimit(1)
                    .truncationMode(.middle)
                Spacer()
                Button("Logout") {
                    authSession.logout()
                }
                .font(.caption.bold())
                .foregroundColor(AppColors.goldColor)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)
            .background(AppColors.blackColor)

            VStack(spacing: TransactionLayout.sectionSpacing) {
                if activeTab == 0 {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: SharedLayout.sectionSpacing) {
                            totalBalanceView
                            actionButtonsRow
                            tokensSection
                        }
                        .padding(.horizontal, SharedLayout.horizontalPadding)
                        .padding(.top, SharedLayout.horizontalPadding)
                        .padding(.bottom, SharedLayout.horizontalPadding)
                    }
                    .background(AppColors.blackColor)
                } else {
                    AllTransactionsView(tokens: tokens)
                }

                HStack {
                    Button {
                        activeTab = 0
                    } label: {
                        VStack(spacing: TabBarLayout.itemSpacing) {
                            Image(systemName: "house.fill")
                                .font(.system(size: TabBarLayout.iconSize))
                            Text("Dashboard")
                                .font(.caption2)
                        }
                        .foregroundColor(activeTab == 0 ? AppColors.goldColor : .gray)
                        .frame(maxWidth: .infinity)
                    }

                    Button {
                        activeTab = 1
                    } label: {
                        VStack(spacing: TabBarLayout.itemSpacing) {
                            Image(systemName: "list.bullet")
                                .font(.system(size: TabBarLayout.iconSize))
                            Text("Transactions")
                                .font(.caption2)
                        }
                        .foregroundColor(activeTab == 1 ? AppColors.goldColor : .gray)
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.vertical, TabBarLayout.verticalPadding)
                .padding(.bottom, TabBarLayout.bottomPadding)
                .background(AppColors.charcoalColor)
            }
            .background(AppColors.blackColor.ignoresSafeArea())
            .sheet(item: $selectedToken) { token in
                TokenViewDetails(token: token, GoBackToDashboard: { selectedToken = nil })
            }
        }
        .background(AppColors.blackColor.ignoresSafeArea())
    }

    private var totalBalanceView: some View {
        VStack(alignment: .center, spacing: BalanceLayout.stackSpacing) {
            Text("Total Balance")
                .font(.system(size: TypographyLayout.labelFontSize, weight: .medium))
                .foregroundColor(AppColors.goldColor)
            Text(formattedBalance)
                .font(.system(size: BalanceLayout.fontSize, weight: .bold))
                .foregroundColor(.white)

            let isGain = totalGainLoss >= 0
            let sign = isGain ? "+" : "-"
            let gainLossColor: Color = isGain ? .green : .red
            Label {
                Text(
                    "\(sign)$\(String(format: BalanceLayout.currencyFormat, abs(totalGainLoss))) (\(sign)\(String(format: BalanceLayout.currencyFormat, abs(totalGainLossPercent)))%)"
                )
                .font(.system(size: GainLossLayout.fontSize, weight: .medium))
                .foregroundColor(gainLossColor)
            } icon: {
                Image(systemName: isGain ? "arrow.up.right" : "arrow.down.right")
                    .font(.system(size: GainLossLayout.iconSize, weight: .bold))
                    .foregroundColor(gainLossColor)
            }
        }
    }

    private var actionButtonsRow: some View {
        HStack(spacing: ActionButtonLayout.rowSpacing) {
            NavigationLink {
                SendView()
            } label: {
                ActionButton(icon: "arrow.right", label: "Send")
                    .allowsHitTesting(false) //disable inner button
            }
            NavigationLink {
                ReceiveView()
            } label: {
                ActionButton(icon: "arrow.down.left", label: "Receive")
                    .allowsHitTesting(false)
            }
        }
    }

    private var tokensSection: some View {
        VStack(alignment: .leading, spacing: TokenLayout.rowSpacing) {
            sectionHeader("Tokens")

            VStack(spacing: TokenLayout.listSpacing) {
                ForEach(Array(tokens.enumerated()), id: \.element.id) { index, token in
                    Button {
                        selectedToken = token
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
                            .background(Color.gray.opacity(SharedLayout.dividerOpacity))
                            .padding(.leading, SharedLayout.dividerLeadingPadding)
                    }
                }
            }
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Button {
        } label: {
            HStack(spacing: SharedLayout.sectionHeaderSpacing) {
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
        .environment(AuthSession())
}
