import Foundation

// MARK: - WalletController

private let walletBase = "/wallet"

extension APIClient {
    // Lists all tokens in the user's wallet.
    func listWalletTokens() async throws -> [TokenResponse] {
        guard accessToken != nil else {
            throw APIError.serverError("You must be logged in to view your wallet.")
        }
        return try await get("\(walletBase)/tokens")
    }
}
