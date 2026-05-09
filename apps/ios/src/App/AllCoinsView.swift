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
                    Text("Loaded \(coins.count) coins.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
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
