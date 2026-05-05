import Foundation

// MARK: - Models

struct WalletBalancesResponse: Decodable {
    let totalValue: Double
}

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

    // Adds a token to the user's wallet by mint address.
    func addWalletToken(mintAddress: String) async throws {
        guard accessToken != nil else {
            throw APIError.serverError("You must be logged in to manage your wallet.")
        }
        try await post("\(walletBase)/tokens/\(mintAddress)")
    }

    // Removes a token from the user's wallet by mint address.
    func removeWalletToken(mintAddress: String) async throws {
        guard accessToken != nil else {
            throw APIError.serverError("You must be logged in to manage your wallet.")
        }
        try await delete("\(walletBase)/tokens/\(mintAddress)")
    }

    // Returns the total portfolio value of all tokens in the user's wallet.
    func getWalletBalance() async throws -> WalletBalancesResponse {
        guard accessToken != nil else {
            throw APIError.serverError("You must be logged in to view your balance.")
        }
        return try await get("\(walletBase)/balance")
    }
}
