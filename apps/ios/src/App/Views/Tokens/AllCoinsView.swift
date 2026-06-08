import SwiftUI

struct AllCoinsView: View {
    @State private var isLoading = false
    @State private var coins: [TokenListResponse] = []
    @State private var errorText = ""

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                Text("Coins")
                    .font(.system(size: TypographyLayout.labelFontSize, weight: .medium))
                    .foregroundColor(AppColors.accent)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, SharedLayout.horizontalPadding)
                    .padding(.bottom, SharedLayout.sectionSpacing)

                if isLoading {
                    ProgressView()
                        .tint(AppColors.ink)
                        .padding(.top, 40)
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
                    .padding(.top, 40)
                } else if coins.isEmpty {
                    ContentUnavailableView(
                        "No Coins Yet",
                        systemImage: "bitcoinsign.circle",
                        description: Text("Coins created on the platform will show here.")
                    )
                    .foregroundStyle(AppColors.ink)
                } else {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(coins.enumerated()), id: \.element.id) { index, coin in
                            NavigationLink {
                                TokenDetailsView(token: coin)
                            } label: {
                                HStack(spacing: 12) {
                                    CachedAsyncImage(url: URL(string: coin.imgUrl)) { phase in
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
                                    }
                                    Spacer()
                                    VStack(alignment: .trailing, spacing: 2) {
                                        Text(String(format: "$%.2f", coin.price))
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(AppColors.ink)
                                        Text(String(format: "%.2f%%", coin.gainsPercent))
                                            .font(.caption)
                                            .foregroundStyle(coin.gainsPercent >= 0 ? AppColors.success : AppColors.error)
                                    }
                                }
                                .padding(.vertical, TokenLayout.rowVerticalPadding)
                            }
                            .buttonStyle(.plain)

                            if index < coins.count - 1 {
                                Divider()
                                    .background(AppColors.secondaryText.opacity(SharedLayout.dividerOpacity))
                                    .padding(.leading, SharedLayout.dividerLeadingPadding)
                            }
                        }
                    }
                    .padding(.horizontal, SharedLayout.horizontalPadding)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .refreshable { await loadAllCoins(showLoadingUI: false) }
        .background(AppColors.canvas)
        .task {
            guard coins.isEmpty else { return }
            await loadAllCoins(showLoadingUI: true)
        }
    }

    @MainActor
    private func loadAllCoins(showLoadingUI: Bool = true) async {
        if showLoadingUI { isLoading = true }
        defer { if showLoadingUI { isLoading = false } }
        do {
            // Artificial delay so users can feel the refresh even on fast/cached responses.
            try? await Task.sleep(for: AppBehavior.artificialRefreshDuration)
            coins = try await APIClient.shared.listAllTokens()
            errorText = ""
        } catch is CancellationError {
        } catch let e as URLError where e.code == .cancelled {
        } catch {
            coins = []
            errorText = error.localizedDescription
        }
    }
}

#Preview {
    AllCoinsView()
}
