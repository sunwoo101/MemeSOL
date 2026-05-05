import Foundation

// MARK: - Models

struct WalletTokenResponse: Decodable {
    let id: String
    let mintAddress: String
    let name: String
    let symbol: String
    let imgUrl: String
    let price: Double
    let balance: Double
    let gainsPercent: Double
}

// MARK: - WalletController

private let walletBase = "/wallet"

extension APIClient {
    // Lists all tokens in the user's wallet with live price and balance data.
    func listWalletTokens() async throws -> [WalletTokenResponse] {
        guard accessToken != nil else {
            throw APIError.serverError("You must be logged in to view your wallet.")
        }
        return try await get("\(walletBase)/tokens")
    }
}
