import SwiftUI

struct AllCoinsView: View {
    @State private var isLoading = false
    @State private var coins: [TokenListResponse] = []
    @State private var errorText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("All Coins")
                    .font(.headline.bold())
                    .foregroundColor(AppColors.ink)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, SharedLayout.horizontalPadding)
            .padding(.top, TransactionLayout.titleTopPadding)
            .padding(.bottom, TransactionLayout.navBarBottomPadding)
            .background(AppColors.canvas)
            
            Group {
                if isLoading {
                    ProgressView("Loading all coins...")
                        .tint(AppColors.ink)
                        .foregroundStyle(AppColors.ink)
                } else if !errorText.isEmpty {
                    VStack(spacing: 12) {
                        Text("Could not load coins")
                            .font(.headline)
                            .foregroundStyle(AppColors.ink)
                        Text(errorText)
                            .font(.footnote)
                            .foregroundStyle(AppColors.secondaryText)
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
                    .foregroundStyle(AppColors.ink)
                } else {
                    List(coins, id: \.id) { coin in
                        NavigationLink {
                            TokenDetailsView(token: coin)
                        } label: {
                            
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
                                        .foregroundStyle(AppColors.ink)
                                    Text(coin.symbol)
                                        .font(.caption)
                                        .foregroundStyle(AppColors.secondaryText)
                                    Text(coin.mintAddress)
                                        .font(.caption2.monospaced())
                                        .foregroundStyle(AppColors.secondaryText)
                                        .lineLimit(1)
                                        .truncationMode(.middle)
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text(String(format: "$%.4f", coin.price))
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(AppColors.ink)
                                    Text(String(format: "%.2f%%", coin.gainsPercent))
                                        .font(.caption)
                                        .foregroundStyle(coin.gainsPercent >= 0 ? AppColors.success : AppColors.error)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .listRowBackground(AppColors.canvas)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(AppColors.canvas)
                    .refreshable {
                        await loadAllCoins(showLoadingUI: false)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColors.canvas)
        }
        .background(AppColors.canvas.ignoresSafeArea())
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
