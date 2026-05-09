import SwiftUI

struct AllCoinsView: View {
    @State private var isLoading = false
    @State private var coins: [TokenListResponse] = []
    @State private var errorText = ""

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Loading all coins...")
                } else if !errorText.isEmpty {
                    VStack(spacing: 12) {
                        Text("Could not load coins")
                            .font(.headline)
                        Text(errorText)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
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
                                Text(coin.symbol)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(coin.mintAddress)
                                    .font(.caption2.monospaced())
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text(String(format: "$%.4f", coin.price))
                                    .font(.subheadline.weight(.semibold))
                                Text(String(format: "%.2f%%", coin.gainsPercent))
                                    .font(.caption)
                                    .foregroundStyle(coin.gainsPercent >= 0 ? .green : .red)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .listStyle(.plain)
                    .refreshable {
                        await loadAllCoins(showLoadingUI: false)
                    }
                }
            }
            .navigationTitle("All Coins")
            .navigationBarTitleDisplayMode(.inline)
        }
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
