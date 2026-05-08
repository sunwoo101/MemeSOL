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
                    Text("Failed to load coins.")
                        .font(.subheadline)
                        .foregroundStyle(.red)
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
                }
            }
            .navigationTitle("All Coins")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            await loadAllCoins()
        }
    }

    @MainActor
    private func loadAllCoins() async {
        isLoading = true
        defer { isLoading = false }
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
