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
        VStack(spacing: TransactionLayout.sectionSpacing) {
            Text("Transactions")
                .font(.title2.bold())
                .foregroundColor(AppColors.goldColor)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, SharedLayout.horizontalPadding)
                .padding(.top, TokenLayout.detailTopPadding)
                .padding(.bottom, SharedLayout.sectionSpacing)
                .background(AppColors.blackColor)

            if isLoading {
                Spacer()
                ProgressView().tint(.white)
                Spacer()
            } else if !errorText.isEmpty {
                Spacer()
                Text(errorText)
                    .foregroundColor(.gray)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding()
                Spacer()
            } else if transactions.isEmpty {
                Spacer()
                Text("No transactions yet.")
                    .foregroundColor(.gray)
                    .font(.subheadline)
                Spacer()
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: TransactionLayout.listSpacing) {
                        ForEach(groupedTransactions, id: \.0) { dateStr, txs in
                            Text(dateStr)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding(.horizontal, SharedLayout.horizontalPadding)
                                .padding(.top, SharedLayout.sectionSpacing)

                            ForEach(txs, id: \.signature) { tx in
                                AllTransactionRow(transaction: tx)
                                Divider()
                                    .background(Color.gray.opacity(SharedLayout.dividerOpacity))
                                    .padding(.leading, SharedLayout.dividerLeadingPadding + SharedLayout.horizontalPadding)
                            }
                        }
                    }
                    .padding(.top, TransactionLayout.listTopPadding)
                    .padding(.bottom, TransactionLayout.listBottomPadding)
                }
                .background(AppColors.blackColor)
            }
        }
        .background(AppColors.blackColor.ignoresSafeArea())
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
            AsyncImage(url: URL(string: transaction.imgUrl)) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    Circle().fill(Color.gray.opacity(0.3))
                }
            }
            .frame(width: TransactionLayout.iconSize, height: TransactionLayout.iconSize)
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: TransactionLayout.textSpacing) {
                Text(transaction.transactionType?.capitalized ?? "Unknown")
                    .font(.subheadline)
                    .foregroundColor(.white)
                Text(transaction.formattedTime)
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()

            Text(transaction.amountText)
                .font(.subheadline)
                .foregroundColor(.white)
        }
        .padding(.horizontal, SharedLayout.horizontalPadding)
        .padding(.vertical, TransactionLayout.rowVerticalPadding)
    }
}

#Preview {
    AllTransactionsView(tokens: [])
}
