//
//  TransactionListView.swift
//  Assignment3
//
//  Created by Daniel Liu on 5/5/2026.
//

import SwiftUI

struct TransactionListView: View {
    let token: Token
    var GoBackToDashboard: () -> Void = {}
    @Environment(\.dismiss) private var dismiss
    @State private var showingSend = false
    @State private var showingReceive = false
    @State private var showingBuy = false
    @State private var transactions: [TransactionHistoryResponse] = []
    @State private var tokenAmount: String = ""
    @State private var liveBalance: String = ""
    @State private var isLoading = false
    @State private var errorText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            tokenBalanceSection
            actionButtons

            if isLoading {
                Spacer()
                ProgressView().tint(AppColors.ink)
                Spacer()
            } else if !errorText.isEmpty {
                Spacer()
                Text(errorText)
                    .foregroundColor(AppColors.secondaryText)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding()
                Spacer()
            } else if transactions.isEmpty {
                Spacer()
                Text("No transactions yet.")
                    .foregroundColor(AppColors.secondaryText)
                    .font(.subheadline)
                Spacer()
            } else {
                transactionList
            }
        }
        .background(AppColors.canvas.ignoresSafeArea())
        .navigationTitle(token.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { Task { await loadTransactions() } }
        .sheet(isPresented: $showingSend, onDismiss: { Task { await loadTransactions() } }) {
            NavigationStack {
                SendView(preselectedMintAddress: token.mintAddress)
            }
        }
        .sheet(isPresented: $showingBuy, onDismiss: { Task { await loadTransactions() } }) {
            let cleanedPrice = token.pricePerToken
                .replacingOccurrences(of: "$", with: "")
                .replacingOccurrences(of: ",", with: "")
            let cleanedPercent = token.percentChange
                .replacingOccurrences(of: "%", with: "")
            NavigationStack {
                BuyTokenView(token: TokenListResponse(id: token.id.uuidString, mintAddress: token.mintAddress, name: token.name, symbol: token.symbol, imgUrl: token.iconUrl, price: Double(cleanedPrice) ?? 0, gainsPercent: Double(cleanedPercent) ?? 0))
            }
        }
        .sheet(isPresented: $showingReceive, onDismiss: { Task { await loadTransactions() } }) {
            NavigationStack {
                ReceiveView()
            }
        }
    }
    
    private var tokenBalanceSection: some View {
        VStack(spacing: BalanceLayout.stackSpacing) {
            Text("Balance")
                .font(.system(size: TypographyLayout.labelFontSize, weight: .medium))
                .foregroundColor(AppColors.accent)
            Text(tokenAmount.isEmpty ? token.symbol : tokenAmount)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(AppColors.ink)
                .multilineTextAlignment(.center)
            if !liveBalance.isEmpty {
                Text(liveBalance)
                    .font(.system(size: TypographyLayout.labelFontSize, weight: .medium))
                    .foregroundColor(AppColors.secondaryText)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 12)
        .background(AppColors.canvas)
    }
    
    private var actionButtons: some View {
        HStack(spacing: TransactionLayout.actionButtonSpacing) {
            TransactionActionButton(icon: "creditcard.fill",        label: "Buy")    { showingBuy    = true }
            TransactionActionButton(icon: "paperplane.fill",        label: "Send")    { showingSend    = true }
            TransactionActionButton(icon: "arrow.down.circle.fill", label: "Receive") { showingReceive = true }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, SharedLayout.sectionSpacing)
        .background(AppColors.canvas)
    }
    
    private var transactionList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: TransactionLayout.listSpacing) {
                ForEach(groupedTransactions, id: \.0) { dateStr, txs in
                    Text(dateStr)
                        .font(.subheadline)
                        .foregroundColor(AppColors.secondaryText)
                        .padding(.horizontal, SharedLayout.horizontalPadding)
                        .padding(.vertical, TransactionLayout.dateVerticalPadding)
                    ForEach(txs, id: \.signature) { tx in
                        TransactionRow(transaction: tx)
                        Divider()
                            .background(AppColors.secondaryText.opacity(SharedLayout.dividerOpacity))
                            .padding(.horizontal, SharedLayout.horizontalPadding)
                    }
                }
            }
            .padding(.top, TransactionLayout.listTopPadding)
            .padding(.bottom, TransactionLayout.listBottomPadding)
        }
        .refreshable { await loadTransactions() }
        .background(AppColors.canvas)
    }
    
    private var groupedTransactions: [(String, [TransactionHistoryResponse])] {
        var groups: [(String, [TransactionHistoryResponse])] = []
        var index: [String: Int] = [:]
        for tx in transactions {
            let key = tx.formattedDate
            if let i = index[key] {
                groups[i].1.append(tx)
            } else {
                index[key] = groups.count
                groups.append((key, [tx]))
            }
        }
        return groups
    }
    
    @MainActor
    private func loadTransactions() async {
        guard !token.mintAddress.isEmpty else {
            errorText = "No mint address for this token."
            return
        }
        isLoading = true
        defer { isLoading = false }
        do {
            async let txFetch = APIClient.shared.getTransactions(mintAddress: token.mintAddress)
            async let walletFetch = APIClient.shared.listWalletTokens()
            let (txs, walletTokens) = try await (txFetch, walletFetch)
            transactions = txs
            if let match = walletTokens.first(where: { $0.mintAddress == token.mintAddress }) {
                let audValue = match.balance * match.price
                tokenAmount = "\(String(format: "%g", match.balance)) \(match.symbol)"
                liveBalance = DashboardView.currencyFormatter.string(from: NSNumber(value: audValue)) ?? token.balance
            }
        } catch {
            errorText = error.localizedDescription
        }
    }
}

// MARK: - Transaction Row

private struct TransactionRow: View {
    let transaction: TransactionHistoryResponse
    
    var body: some View {
        HStack(spacing: TransactionLayout.rowSpacing) {
            AsyncImage(url: URL(string: transaction.imgUrl)) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    Circle().fill(AppColors.secondaryText.opacity(0.3))
                }
            }
            .frame(width: TransactionLayout.iconSize, height: TransactionLayout.iconSize)
            .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: TransactionLayout.textSpacing) {
                Text(transaction.transactionType?.capitalized ?? "Unknown")
                    .font(.subheadline)
                    .foregroundColor(AppColors.ink)
                Text(transaction.formattedTime)
                    .font(.caption)
                    .foregroundColor(AppColors.secondaryText)
            }
            
            Spacer()
            
            Text(transaction.amountText)
                .font(.subheadline)
                .foregroundColor(AppColors.ink)
        }
        .padding(.horizontal, SharedLayout.horizontalPadding)
        .padding(.vertical, TransactionLayout.rowVerticalPadding)
    }
}

// MARK: - Action Button

private struct TransactionActionButton: View {
    let icon: String
    let label: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: ActionButtonLayout.contentSpacing) {
                Image(systemName: icon)
                    .font(.system(size: ActionButtonLayout.iconSize))
                    .foregroundColor(AppColors.ink)
                    .frame(width: TransactionLayout.actionButtonSize, height: TransactionLayout.actionButtonSize)
                    .background(AppColors.surface)
                    .clipShape(Circle())
                Text(label)
                    .font(.caption)
                    .foregroundColor(AppColors.secondaryText)
            }
        }
    }
}

// MARK: - TransactionHistoryResponse helpers

extension TransactionHistoryResponse {
    fileprivate static let isoFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()
    
    fileprivate static let isoFormatterPlain: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()
    
    fileprivate static let dateHeaderFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .long
        f.timeStyle = .none
        return f
    }()
    
    fileprivate static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()
    
    fileprivate var parsedDate: Date? {
        TransactionHistoryResponse.isoFormatter.date(from: timestamp)
        ?? TransactionHistoryResponse.isoFormatterPlain.date(from: timestamp)
    }
    
    var formattedDate: String {
        parsedDate.map { TransactionHistoryResponse.dateHeaderFormatter.string(from: $0) } ?? timestamp
    }
    
    var formattedTime: String {
        parsedDate.map { TransactionHistoryResponse.timeFormatter.string(from: $0) } ?? ""
    }
    
    var amountText: String {
        guard let amt = amount else { return tokenSymbol }
        let sign = transactionType == "sent" ? "-" : "+"
        let numStr = amt.truncatingRemainder(dividingBy: 1) == 0
        ? String(format: "%.0f", amt)
        : String(format: "%g", amt)
        return "\(sign)\(numStr) \(tokenSymbol)"
    }
}

#Preview {
    TransactionListView(token: Token(
        name: "Bitcoin", symbol: "BTC",
        pricePerToken: "A$98,430.00", balance: "A$2,952.90",
        percentChange: "+1.1%", positive: true,
        iconUrl: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png",
        color: .orange, mintAddress: ""
    ))
}
