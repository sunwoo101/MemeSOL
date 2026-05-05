//
//  AllTransactionsView.swift
//  Assignment3
//
//  Created by Daniel Liu on 05/5/2026.
//

import SwiftUI

struct TokenTransactionGroup {
    let token: Token
    let transactions: [MockTransaction]
}

struct AllTransactionsView: View {
    let tokens: [Token]

    private let groups: [TokenTransactionGroup] = [
        TokenTransactionGroup(token: Token(
            name: "Ethereum", symbol: "ETH", pricePerToken: "A$3,241.50", balance: "A$4,862.25",
            percentChange: "+2.4%", positive: true,
            iconUrl: "https://assets.coingecko.com/coins/images/279/large/ethereum.png", color: .blue
        ), transactions: [
            MockTransaction(type: "Sent",     time: "23:27", amount: "-0.5 ETH",   value: "A$1,620.75"),
            MockTransaction(type: "Received", time: "22:25", amount: "+0.47 ETH",  value: "A$1,523.50"),
            MockTransaction(type: "Received", time: "19:49", amount: "+0.005 ETH", value: "A$16.20"),
            MockTransaction(type: "Sent",     time: "14:10", amount: "-0.1 ETH",   value: "A$324.15"),
        ]),
        TokenTransactionGroup(token: Token(
            name: "Bitcoin", symbol: "BTC", pricePerToken: "A$98,430.00", balance: "A$2,952.90",
            percentChange: "+1.1%", positive: true,
            iconUrl: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png", color: .orange
        ), transactions: [
            MockTransaction(type: "Received", time: "21:10", amount: "+0.02 BTC",  value: "A$1,968.60"),
            MockTransaction(type: "Sent",     time: "15:45", amount: "-0.01 BTC",  value: "A$984.30"),
        ]),
        TokenTransactionGroup(token: Token(
            name: "Solana", symbol: "SOL", pricePerToken: "A$142.30", balance: "A$1,423.00",
            percentChange: "-3.8%", positive: false,
            iconUrl: "https://assets.coingecko.com/coins/images/4128/large/solana.png", color: .purple
        ), transactions: [
            MockTransaction(type: "Received", time: "18:30", amount: "+5 SOL",     value: "A$711.50"),
            MockTransaction(type: "Sent",     time: "11:00", amount: "-2 SOL",     value: "A$284.60"),
        ]),
        TokenTransactionGroup(token: Token(
            name: "Chainlink", symbol: "LINK", pricePerToken: "A$13.75", balance: "A$1,007.52",
            percentChange: "-1.2%", positive: false,
            iconUrl: "https://assets.coingecko.com/coins/images/877/large/chainlink-new-logo.png", color: .cyan
        ), transactions: [
            MockTransaction(type: "Received", time: "09:15", amount: "+20 LINK",   value: "A$275.00"),
            MockTransaction(type: "Sent",     time: "08:00", amount: "-10 LINK",   value: "A$137.50"),
        ]),
    ]

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

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: TransactionLayout.listSpacing) {
                    Text("May 5, 2026")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.horizontal, SharedLayout.horizontalPadding)

                    ForEach(groups, id: \.token.id) { group in
                        groupHeader(group.token)

                        ForEach(group.transactions) { tx in
                            AllTransactionRow(transaction: tx, tokenColor: group.token.color)
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
        .background(AppColors.blackColor.ignoresSafeArea())
    }

    private func groupHeader(_ token: Token) -> some View {
        HStack(spacing: TokenLayout.rowIconSpacing) {
            AsyncImage(url: URL(string: token.iconUrl)) { phase in
                switch phase {
                case .success(let image): image.resizable().scaledToFit()
                default:
                    Image(systemName: "circle.fill")
                        .resizable().scaledToFit()
                        .foregroundColor(token.color)
                }
            }
            .frame(width: TransactionLayout.iconSize, height: TransactionLayout.iconSize)
            .clipShape(Circle())

            Text(token.name)
                .font(.subheadline.bold())
                .foregroundColor(.white)
        }
        .padding(.horizontal, SharedLayout.horizontalPadding)
        .padding(.top, SharedLayout.sectionSpacing)
    }
}

private struct AllTransactionRow: View {
    let transaction: MockTransaction
    let tokenColor: Color

    var body: some View {
        HStack(spacing: TransactionLayout.rowSpacing) {
            Image(systemName: transaction.isSent ? "paperplane.fill" : "arrow.down.circle.fill")
                .foregroundColor(transaction.isSent ? .gray : .green)
                .frame(width: TransactionLayout.iconSize, height: TransactionLayout.iconSize)
                .background(AppColors.charcoalColor)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: TransactionLayout.textSpacing) {
                Text(transaction.type)
                    .font(.subheadline)
                    .foregroundColor(.white)
                Text(transaction.time)
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: TransactionLayout.textSpacing) {
                Text(transaction.amount)
                    .font(.subheadline)
                    .foregroundColor(.white)
                Text(transaction.value)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, SharedLayout.horizontalPadding)
        .padding(.vertical, TransactionLayout.rowVerticalPadding)
    }
}

#Preview {
    AllTransactionsView(tokens: [])
}
