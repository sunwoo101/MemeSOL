//
//  AllTransactionsView.swift
//  Assignment3
//
//  Created by Daniel Liu on 05/5/2026.
//

import SwiftUI

struct AllTransactionsView: View {
    let tokens: [Token]

    @State private var transactions: [TransactionHistoryResponse] = []
    @State private var isLoading = false
    @State private var errorText = ""

    var body: some View {
        VStack(spacing: SharedLayout.sectionSpacing) {
            Text("Transactions")
                .font(.system(size: TypographyLayout.labelFontSize, weight: .medium))
                .foregroundColor(AppColors.accent)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, SharedLayout.horizontalPadding)
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
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: TransactionLayout.listSpacing) {
                        ForEach(groupedTransactions, id: \.0) { dateStr, txs in
                            Text(dateStr)
                                .font(.subheadline)
                                .foregroundColor(AppColors.secondaryText)
                                .padding(.horizontal, SharedLayout.horizontalPadding)
                                .padding(.top, SharedLayout.sectionSpacing)

                            ForEach(txs, id: \.signature) { tx in
                                AllTransactionRow(transaction: tx)
                                Divider()
                                    .background(AppColors.secondaryText.opacity(SharedLayout.dividerOpacity))
                                    .padding(.leading, SharedLayout.dividerLeadingPadding + SharedLayout.horizontalPadding)
                            }
                        }
                    }
                    .padding(.top, TransactionLayout.listTopPadding)
                    .padding(.bottom, TransactionLayout.listBottomPadding)
                }
                .background(AppColors.canvas)
            }
        }
        .frame(maxWidth: .infinity)
        .background(AppColors.canvas.ignoresSafeArea())
        .task { await loadTransactions() }
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
        isLoading = true
        defer { isLoading = false }
        do {
            transactions = try await APIClient.shared.getAllTransactions()
        } catch {
            errorText = error.localizedDescription
        }
    }
}

private struct AllTransactionRow: View {
    let transaction: TransactionHistoryResponse

    var body: some View {
        HStack(spacing: TransactionLayout.rowSpacing) {
            CachedAsyncImage(url: URL(string: transaction.imgUrl)) { phase in
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

#Preview {
    AllTransactionsView(tokens: [])
}
