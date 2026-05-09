//
//  Dashboard.swift
//  Assignment3
//
//  Created by Daniel Liu on 05/5/2026.
//

import SwiftUI

struct DashboardView: View {
    @Environment(AuthSession.self) private var authSession

    @State private var totalBalance: Double = 0
    @State private var totalGainLoss: Double = 0
    @State private var totalGainLossPercent: Double = 0
    @State private var selectedToken: Token? = nil
    @State private var activeTab: Int = 0
    @State private var tokens: [Token] = []
    @State private var isLoading = false
    @State private var isReceiveSheetPresented = false

    private var formattedBalance: String {
        Self.currencyFormatter.string(from: NSNumber(value: totalBalance)) ?? "A$0.00"
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
                } else if activeTab == 1 {
                    AllTransactionsView(tokens: tokens)
                } else {
                    AllCoinsView()
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

                    Button {
                        activeTab = 2
                    } label: {
                        VStack(spacing: TabBarLayout.itemSpacing) {
                            Image(systemName: "bitcoinsign.circle.fill")
                                .font(.system(size: TabBarLayout.iconSize))
                            Text("Coins")
                                .font(.caption2)
                        }
                        .foregroundColor(activeTab == 2 ? AppColors.goldColor : .gray)
                        .frame(maxWidth: .infinity)
                    }
                    .accessibilityLabel("Show coins")
                }
                .padding(.vertical, TabBarLayout.verticalPadding)
                .padding(.bottom, TabBarLayout.bottomPadding)
                .background(AppColors.charcoalColor)
            }
            .background(AppColors.blackColor.ignoresSafeArea())
            .sheet(item: $selectedToken) { token in
                TransactionListView(token: token, GoBackToDashboard: { selectedToken = nil })
            }
        }
        .background(AppColors.blackColor.ignoresSafeArea())
        .task { await loadDashboard() }
    }

    // MARK: - Subviews

    private var totalBalanceView: some View {
        VStack(alignment: .center, spacing: BalanceLayout.stackSpacing) {
            Text("Total Balance")
                .font(.system(size: TypographyLayout.labelFontSize, weight: .medium))
                .foregroundColor(AppColors.goldColor)

            if isLoading {
                ProgressView().tint(.white)
                    .frame(height: BalanceLayout.fontSize)
            } else {
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
    }

    private var actionButtonsRow: some View {
        HStack(spacing: ActionButtonLayout.rowSpacing) {
            
            NavigationLink {
                SendView()
            } label: {
                ActionButton(icon: "arrow.right", label: "Send")
                    .allowsHitTesting(false)
            }

            
            NavigationLink {
                ReceiveView()
            } label: {
                ActionButton(icon: "arrow.down.left", label: "Receive")
                    .allowsHitTesting(false)
            }
            
            NavigationLink {
                CreateTokenView()
            } label: {
                ActionButton(icon: "pencil", label: "Create")
                    .allowsHitTesting(false)
            }
            
            
        }
    }

    private var tokensSection: some View {
        VStack(alignment: .leading, spacing: TokenLayout.rowSpacing) {
            sectionHeader("Tokens")

            if isLoading {
                ProgressView().tint(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.top, SharedLayout.sectionSpacing)
            } else if tokens.isEmpty {
                Text("No tokens in wallet.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, SharedLayout.sectionSpacing)
            } else {
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
    }

    private func sectionHeader(_ title: String) -> some View {
        HStack(spacing: SharedLayout.sectionHeaderSpacing) {
            Text(title)
                .font(.headline.bold())
                .foregroundColor(.white)
            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundColor(.gray)
        }
    }

    // MARK: - Data loading

    @MainActor
    private func loadDashboard() async {
        isLoading = true
        defer { isLoading = false }
        async let tokensFetch = APIClient.shared.listWalletTokens()
        async let balanceFetch = APIClient.shared.getWalletBalance()
        do {
            let (walletTokens, walletBalance) = try await (tokensFetch, balanceFetch)
            tokens = walletTokens.map { Token(walletToken: $0) }
            totalBalance = walletBalance.totalValue
            totalGainLoss = walletBalance.gainLoss
            totalGainLossPercent = walletBalance.gainLossPercent
        } catch {
            // balance/tokens stay at zero/empty — user can see empty state
        }
    }

    // MARK: - Helpers

    static let currencyFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "AUD"
        return f
    }()
}

// MARK: - WalletTokenResponse → Token mapping

private extension Token {
    init(walletToken w: WalletTokenResponse) {
        let fmt = DashboardView.currencyFormatter
        let audBalance = w.balance * w.price
        let pct = w.gainsPercent
        self.init(
            name: w.name,
            symbol: w.symbol,
            pricePerToken: fmt.string(from: NSNumber(value: w.price)) ?? "A$0.00",
            balance: fmt.string(from: NSNumber(value: audBalance)) ?? "A$0.00",
            percentChange: "\(pct >= 0 ? "+" : "")\(String(format: "%.2f", pct))%",
            positive: pct >= 0,
            iconUrl: w.imgUrl,
            color: Token.color(for: w.symbol),
            mintAddress: w.mintAddress
        )
    }

    private static func color(for symbol: String) -> Color {
        let palette: [Color] = [.blue, .orange, .purple, .cyan, .green, .red, .yellow, .pink, .indigo, .teal]
        let hash = symbol.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        return palette[hash % palette.count]
    }
}

#Preview {
    DashboardView()
        .environment(AuthSession())
}
