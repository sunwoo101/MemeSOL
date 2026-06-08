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
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: SharedLayout.sectionSpacing) {
                Text("Transactions")
                    .font(.system(size: TypographyLayout.labelFontSize, weight: .medium))
                    .foregroundColor(AppColors.accent)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, SharedLayout.horizontalPadding)
                if isLoading {
                    ProgressView().tint(AppColors.ink)
                        .padding(.top, 40)
                } else if !errorText.isEmpty {
                    Text(errorText)
                        .foregroundColor(AppColors.secondaryText)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding()
                        .padding(.top, 60)
                } else if transactions.isEmpty {
                    ContentUnavailableView(
                        "No Transactions Yet",
                        systemImage: "list.bullet.rectangle",
                        description: Text("Your transactions will show here.")
                    )
                    .foregroundStyle(AppColors.ink)
                } else {
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
                                    .padding(.trailing, SharedLayout.horizontalPadding)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, TransactionLayout.listTopPadding)
                    .padding(.bottom, TransactionLayout.listBottomPadding)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .refreshable { await loadTransactions() }
        .background(AppColors.canvas)
        .task {
            guard transactions.isEmpty else { return }
            await loadTransactions()
        }
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
        if transactions.isEmpty { isLoading = true }
        errorText = ""
        defer { isLoading = false }
        do {
            // Artificial delay so users can feel the refresh even on fast/cached responses.
            try? await Task.sleep(for: AppBehavior.artificialRefreshDuration)
            transactions = try await APIClient.shared.getAllTransactions()
        } catch is CancellationError {
        } catch let e as URLError where e.code == .cancelled {
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
