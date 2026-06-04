//
//  Dashboard.swift
//  Assignment3
//
//  Created by Daniel Liu on 05/5/2026.
//xx

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
    @State private var isCreateTokenPresented = false

    private var formattedBalance: String {
        Self.currencyFormatter.string(from: NSNumber(value: totalBalance)) ?? "A$0.00"
    }
    
    var body: some View {
        TabView(selection: $activeTab) {
            Tab("Dashboard", systemImage: "house.fill", value: 0) {
                NavigationStack {
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
                    .refreshable { await loadDashboard() }
                    .background(AppColors.canvas)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Logout") {
                                authSession.logout()
                            }
                            .foregroundColor(AppColors.accent)
                        }
                    }
                }
            }

            Tab("Transactions", systemImage: "list.bullet", value: 1) {
                NavigationStack {
                    AllTransactionsView(tokens: tokens)
                }
            }

            Tab("Coins", systemImage: "bitcoinsign.circle.fill", value: 2) {
                NavigationStack {
                    AllCoinsView()
                }
            }
        }
        .preferredColorScheme(.dark)
        .sheet(item: $selectedToken, onDismiss: { Task { await loadDashboard() } }) { token in
            TransactionListView(token: token, GoBackToDashboard: { selectedToken = nil })
        }
        .onAppear { Task { await loadDashboard() } }
    }
    
    // MARK: - Subviews
    
    private var totalBalanceView: some View {
        VStack(alignment: .center, spacing: BalanceLayout.stackSpacing) {
            Text("Total Balance")
                .font(.system(size: TypographyLayout.labelFontSize, weight: .medium))
                .foregroundColor(AppColors.accent)
            
            if isLoading {
                ProgressView().tint(AppColors.ink)
                    .frame(height: BalanceLayout.fontSize)
            } else {
                Text(formattedBalance)
                    .font(.system(size: BalanceLayout.fontSize, weight: .bold))
                    .foregroundColor(AppColors.ink)
                
                let isGain = totalGainLoss >= 0
                let sign = isGain ? "+" : "-"
                let gainLossColor: Color = isGain ? AppColors.success : AppColors.error
                let formattedGainLoss = Self.currencyFormatter.string(from: NSNumber(value: abs(totalGainLoss))) ?? "$0.00"
                Label {
                    Text(
                        "\(sign)\(formattedGainLoss) (\(sign)\(String(format: BalanceLayout.currencyFormat, abs(totalGainLossPercent)))%)"
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
                BuyMenuView()
            } label: {
                ActionButton(icon: "cart.fill", label: "Buy")
            }
            
            NavigationLink {
                SendView()
            } label: {
                ActionButton(icon: "arrow.right", label: "Send")
            }
            
            NavigationLink {
                ReceiveView()
            } label: {
                ActionButton(icon: "arrow.down.left", label: "Receive")
            }
            Button { isCreateTokenPresented = true } label: {
                ActionButton(icon: "pencil", label: "Create")
            }
            .navigationDestination(isPresented: $isCreateTokenPresented) {
                CreateTokenView(onDone: { isCreateTokenPresented = false })
            }
        }
    }
    
    private var tokensSection: some View {
        VStack(alignment: .leading, spacing: TokenLayout.rowSpacing) {
            sectionHeader("Tokens")
            
            if isLoading {
                ProgressView().tint(AppColors.ink)
                    .frame(maxWidth: .infinity)
                    .padding(.top, SharedLayout.sectionSpacing)
            } else if tokens.isEmpty {
                Text("No tokens in wallet.")
                    .font(.subheadline)
                    .foregroundColor(AppColors.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, SharedLayout.sectionSpacing)
            } else {
                VStack(spacing: TokenLayout.listSpacing) {
                    ForEach(Array(tokens.enumerated()), id: \.element.id) { index, token in
                        NavigationLink {
                            TransactionListView(token: token)
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
                                .background(AppColors.secondaryText.opacity(SharedLayout.dividerOpacity))
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
                .foregroundColor(AppColors.ink)
            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundColor(AppColors.secondaryText)
        }
    }
    
    // MARK: - Data loading
    
    @MainActor
    private func loadDashboard() async {
        if tokens.isEmpty { isLoading = true }
        defer { isLoading = false }
        async let tokensFetch = APIClient.shared.listWalletTokens()
        async let balanceFetch = APIClient.shared.getWalletBalance()
        if let walletTokens = try? await tokensFetch {
            tokens = walletTokens.map { Token(walletToken: $0) }
            totalBalance = walletTokens.reduce(0) { $0 + $1.balance * $1.price }
        }
        if let walletBalance = try? await balanceFetch {
            totalGainLoss = walletBalance.gainLoss
            totalGainLossPercent = walletBalance.gainLossPercent
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
        let palette: [Color] = [AppColors.accent, AppColors.info, AppColors.success, AppColors.warning, AppColors.error]
        let hash = symbol.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        return palette[hash % palette.count]
    }
}

#Preview {
    DashboardView()
        .environment(AuthSession())
}
