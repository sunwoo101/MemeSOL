import SwiftUI

struct AllCoinsView: View {
    @Environment(\.dismiss) private var dismiss
    var onBack: (() -> Void)? = nil

    @State private var isLoading = false
    @State private var coins: [TokenListResponse] = []
    @State private var errorText = ""

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "chevron.left")
                    .foregroundColor(.white)
                    .font(.body.weight(.semibold))
                    .onTapGesture {
                        if let onBack {
                            onBack()
                        } else {
                            dismiss()
                        }
                    }
                    .accessibilityLabel("Back to dashboard")
                Spacer()
                Text("All Coins")
                    .font(.headline.bold())
                    .foregroundColor(.white)
                Spacer()
                Color.clear.frame(width: 14, height: 14)
            }
            .padding(.horizontal, SharedLayout.horizontalPadding)
            .padding(.top, TransactionLayout.titleTopPadding)
            .padding(.bottom, TransactionLayout.navBarBottomPadding)
            .background(AppColors.blackColor)

            Group {
                if isLoading {
                    ProgressView("Loading all coins...")
                        .tint(.white)
                        .foregroundStyle(.white)
                } else if !errorText.isEmpty {
                    VStack(spacing: 12) {
                        Text("Could not load coins")
                            .font(.headline)
                            .foregroundStyle(.white)
                        Text(errorText)
                            .font(.footnote)
                            .foregroundStyle(AppColors.secondaryTextColor)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                        Button("Try Again") {
                            Task { await loadAllCoins() }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if coins.isEmpty {
                    ContentUnavailableView(
                        "No Coins Yet",
                        systemImage: "bitcoinsign.circle",
                        description: Text("Coins created on the platform will show here.")
                    )
                    .foregroundStyle(.white)
                } else {
                    List(coins, id: \.id) { coin in
                        HStack(spacing: 12) {
                            AsyncImage(url: URL(string: coin.imgUrl)) { phase in
                                switch phase {
                                case .success(let image):
                                    image.resizable().scaledToFill()
                                default:
                                    Color.secondary.opacity(0.2)
                                }
                            }
                            .frame(width: 42, height: 42)
                            .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 2) {
                                Text(coin.name)
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                Text(coin.symbol)
                                    .font(.caption)
                                    .foregroundStyle(AppColors.secondaryTextColor)
                                Text(coin.mintAddress)
                                    .font(.caption2.monospaced())
                                    .foregroundStyle(AppColors.secondaryTextColor)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text(String(format: "$%.4f", coin.price))
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.white)
                                Text(String(format: "%.2f%%", coin.gainsPercent))
                                    .font(.caption)
                                    .foregroundStyle(coin.gainsPercent >= 0 ? .green : .red)
                            }
                        }
                        .padding(.vertical, 4)
                        .listRowBackground(AppColors.blackColor)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(AppColors.blackColor)
                    .refreshable {
                        await loadAllCoins(showLoadingUI: false)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColors.blackColor)
        }
        .background(AppColors.blackColor.ignoresSafeArea())
        .task {
            await loadAllCoins(showLoadingUI: true)
        }
    }

    @MainActor
    private func loadAllCoins(showLoadingUI: Bool = true) async {
        if showLoadingUI {
            isLoading = true
        }
        defer {
            if showLoadingUI {
                isLoading = false
            }
        }
        do {
            coins = try await APIClient.shared.listAllTokens()
            errorText = ""
        } catch {
            coins = []
            errorText = error.localizedDescription
        }
    }
}

#Preview {
    AllCoinsView()
}
