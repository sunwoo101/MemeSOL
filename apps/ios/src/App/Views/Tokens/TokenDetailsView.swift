//
//  TokenDetailsView.swift
//  App
//
//  Created by Gurpreet on 8/5/2026.
//

import SwiftUI

struct TokenDetailsView: View {
    let token: TokenListResponse

    @StateObject var viewModel = TokenDetailsViewModel()

    var body: some View {
        ZStack {
            AppColors.canvas.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    TokenHeaderView(token: token)

                    VStack(spacing: 8) {
                        Text("Your Balance")
                            .font(.subheadline)
                            .foregroundColor(AppColors.secondaryText)
                        Text("\(viewModel.walletToken?.balance ?? 0, specifier: "%.2f") \(token.symbol)")
                            .font(.title.bold())
                            .foregroundColor(AppColors.ink)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.surface)
                    .cornerRadius(SharedLayout.cornerRadius)

                    if viewModel.isLoading {
                        ProgressView()
                            .tint(AppColors.ink)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.surface)
                            .cornerRadius(SharedLayout.cornerRadius)
                    } else {
                        PrimaryButton(
                            label: viewModel.isInWallet ? "Remove from Wallet" : "Add to Wallet",
                            destructive: viewModel.isInWallet
                        ) {
                            Task {
                                if viewModel.isInWallet {
                                    try await APIClient.shared.removeWalletToken(mintAddress: token.mintAddress)
                                } else {
                                    try await APIClient.shared.addWalletToken(mintAddress: token.mintAddress)
                                }
                                await viewModel.checkIfInWallet(mintAddress: token.mintAddress)
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 20) {
                        Text("Recent Transactions")
                            .font(.headline)
                            .foregroundColor(AppColors.ink)

                        if viewModel.transactions.isEmpty {
                            Text("No transactions yet.")
                                .font(.subheadline)
                                .foregroundColor(AppColors.secondaryText)
                        } else {
                            ForEach(viewModel.transactions, id: \.signature) { tx in
                                let isIncoming = tx.transactionType == "received"
                                let sign = isIncoming ? "+" : "-"
                                let amount = "\(sign)\(tx.amount ?? 0) \(tx.tokenSymbol)"

                                HStack(spacing: 14) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(tx.transactionType?.capitalized ?? "Unknown")
                                            .font(.subheadline.weight(.medium))
                                            .foregroundColor(AppColors.ink)
                                        Text("\(tx.formattedDate), \(tx.formattedTime)")
                                            .font(.caption)
                                            .foregroundColor(AppColors.secondaryText)
                                    }
                                    Spacer()
                                    Text(amount)
                                        .font(.subheadline.weight(.medium))
                                        .foregroundColor(isIncoming ? AppColors.success : AppColors.ink)
                                }

                                Divider()
                                    .background(AppColors.secondaryText.opacity(SharedLayout.dividerOpacity))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(AppColors.surface)
                    .cornerRadius(SharedLayout.cornerRadius)
                }
                .padding(SharedLayout.horizontalPadding)
            }
        }
        .refreshable {
            await viewModel.loadAll(mintAddress: token.mintAddress)
        }
        .onAppear {
            Task { await viewModel.loadAll(mintAddress: token.mintAddress) }
        }
    }
}

#Preview {
    TokenDetailsView(token: TokenListResponse(id: "1", mintAddress: "ahifh1i1fiwq13", name: "Bitcoin", symbol: "BTC", imgUrl: "", price: 121.1, gainsPercent: 2.4))
}
