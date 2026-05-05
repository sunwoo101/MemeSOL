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

    let transactions: [MockTransaction] = [
        MockTransaction(type: "Sent", time: "23:27", amount: "-0.5 ETH", value: "A$1,620.75"),
        MockTransaction(type: "Received", time: "22:25", amount: "+0.47 ETH", value: "A$1,523.50"),
        MockTransaction(type: "Received", time: "19:49", amount: "+0.005 ETH", value: "A$16.20"),
        MockTransaction(type: "Sent", time: "14:10", amount: "-0.1 ETH", value: "A$324.15"),
    ]

    var body: some View {
        VStack(spacing: AppLayout.transactionSectionSpacing) {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .font(.body.weight(.semibold))
                }
                Spacer()
                Text("\(token.name) Transactions")
                    .font(.title3.bold())
                    .foregroundColor(AppColors.goldColor)
                Spacer()
                Color.clear.frame(width: AppLayout.transactionNavBarSpacerWidth, height: AppLayout.transactionNavBarSpacerHeight)
            }
            .padding(.horizontal, AppLayout.horizontalPadding)
            .padding(.top, AppLayout.transactionTitleTopPadding)
            .padding(.bottom, AppLayout.transactionNavBarBottomPadding)
            .background(AppColors.blackColor)

            AsyncImage(url: URL(string: token.iconUrl)) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                Circle()
                    .fill(token.color.opacity(AppLayout.transactionIconPlaceholderOpacity))
            }
            .frame(width: AppLayout.tokenDetailIconSize, height: AppLayout.tokenDetailIconSize)
            .clipShape(Circle())
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppLayout.sectionSpacing)
            .background(AppColors.blackColor)

            HStack(spacing: AppLayout.transactionActionButtonSpacing) {
                TransactionActionButton(icon: "paperplane.fill",        label: "Send")    { showingSend    = true }
                TransactionActionButton(icon: "arrow.down.circle.fill", label: "Receive") { showingReceive = true }
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, AppLayout.sectionSpacing)
            .background(AppColors.blackColor)

            ScrollView {
                VStack(alignment: .leading, spacing: AppLayout.transactionListSpacing) {
                    Text("May 5, 2026")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.horizontal, AppLayout.horizontalPadding)
                        .padding(.vertical, AppLayout.transactionDateVerticalPadding)

                    ForEach(transactions) { tx in
                        TransactionRow(transaction: tx)
                        Divider()
                            .background(Color.gray.opacity(AppLayout.dividerOpacity))
                            .padding(.horizontal, AppLayout.horizontalPadding)
                    }
                }
                .padding(.top, AppLayout.transactionListTopPadding)
                .padding(.bottom, AppLayout.transactionListBottomPadding)
            }
            .background(AppColors.blackColor)

            HStack {
                Button { GoBackToDashboard() } label: {
                    VStack(spacing: AppLayout.tabBarItemSpacing) {
                        Image(systemName: "house.fill")
                            .font(.system(size: AppLayout.tabBarIconSize))
                        Text("Dashboard")
                            .font(.caption2)
                    }
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                }

                VStack(spacing: AppLayout.tabBarItemSpacing) {
                    Image(systemName: "list.bullet")
                        .font(.system(size: AppLayout.tabBarIconSize))
                    Text("Transactions")
                        .font(.caption2)
                }
                .foregroundColor(AppColors.goldColor)
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, AppLayout.tabBarVerticalPadding)
            .padding(.bottom, AppLayout.tabBarBottomPadding)
            .background(AppColors.charcoalColor)
        }
        .background(AppColors.blackColor.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .alert("Send \(token.symbol)", isPresented: $showingSend) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Send functionality coming soon.")
        }
        .alert("Receive \(token.symbol)", isPresented: $showingReceive) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Receive functionality coming soon.")
        }
    }
}

private struct TransactionRow: View {
    let transaction: MockTransaction

    var body: some View {
        HStack(spacing: AppLayout.transactionRowSpacing) {
            transactionIcon
            transactionLabel
            Spacer()
            transactionAmount
        }
        .padding(.horizontal, AppLayout.horizontalPadding)
        .padding(.vertical, AppLayout.transactionRowVerticalPadding)
    }

    private var transactionIcon: some View {
        Image(systemName: transaction.isSent ? "paperplane.fill" : "arrow.down.circle.fill")
            .foregroundColor(transaction.isSent ? .gray : .green)
            .frame(width: AppLayout.transactionIconSize, height: AppLayout.transactionIconSize)
            .background(AppColors.charcoalColor)
            .clipShape(Circle())
    }

    private var transactionLabel: some View {
        VStack(alignment: .leading, spacing: AppLayout.transactionTextSpacing) {
            Text(transaction.type)
                .font(.subheadline)
                .foregroundColor(.white)
            Text(transaction.time)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }

    private var transactionAmount: some View {
        VStack(alignment: .trailing, spacing: AppLayout.transactionTextSpacing) {
            Text(transaction.amount)
                .font(.subheadline)
                .foregroundColor(.white)
            Text(transaction.value)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

private struct TransactionActionButton: View {
    let icon: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: AppLayout.actionButtonContentSpacing) {
                Image(systemName: icon)
                    .font(.system(size: AppLayout.actionButtonIconSize))
                    .foregroundColor(.white)
                    .frame(width: AppLayout.transactionActionButtonSize, height: AppLayout.transactionActionButtonSize)
                    .background(AppColors.charcoalColor)
                    .clipShape(Circle())
                Text(label)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

struct MockTransaction: Identifiable {
    let id = UUID()
    let type: String
    let time: String
    let amount: String
    let value: String

    var isSent: Bool {
        type == "Sent"
    }
}

#Preview {
    NavigationStack {
        TransactionListView(token: Token(
            name: "Bitcoin", symbol: "BTC",
            pricePerToken: "A$98,430.00", balance: "A$2,952.90",
            percentChange: "+1.1%", positive: true,
            iconUrl: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png",
            color: .orange
        ))
    }
}
