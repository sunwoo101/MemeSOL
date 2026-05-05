import Foundation

// MARK: - Models

struct TransactionHistoryResponse: Decodable {
    let signature: String
    let timestamp: String
    let success: Bool
    let mintAddress: String
    let tokenName: String
    let tokenSymbol: String
    let imgUrl: String
    let amount: Double?
    let transactionType: String?
}

struct WalletBalancesResponse: Decodable {
    let totalValue: Double
    let gainLoss: Double
    let gainLossPercent: Double
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

    // Mints tokens to the user's wallet. Amount is in token units (not $).
    func buyToken(mintAddress: String, amount: Decimal) async throws -> SendTokenResponse {
        guard accessToken != nil else {
            throw APIError.serverError("You must be logged in to buy tokens.")
        }
        guard amount > 0 else {
            throw APIError.serverError("Amount must be greater than zero.")
        }
        struct Body: Encodable { let amount: Decimal }
        return try await post("\(walletBase)/tokens/\(mintAddress)/buy", body: Body(amount: amount))
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

    // Returns transactions across all tokens in the user's wallet, sorted by timestamp.
    func getAllTransactions() async throws -> [TransactionHistoryResponse] {
        guard accessToken != nil else {
            throw APIError.serverError("You must be logged in to view transactions.")
        }
        return try await get("\(walletBase)/transactions")
    }

    // Returns the transaction history for the authenticated user's wallet and a specific token mint.
    func getTransactions(mintAddress: String) async throws -> [TransactionHistoryResponse] {
        guard accessToken != nil else {
            throw APIError.serverError("You must be logged in to view transactions.")
        }
        return try await get("\(walletBase)/\(mintAddress)/transactions")
    }

    // Returns the total portfolio value of all tokens in the user's wallet.
    func getWalletBalance() async throws -> WalletBalancesResponse {
        guard accessToken != nil else {
            throw APIError.serverError("You must be logged in to view your balance.")
        }
        return try await get("\(walletBase)/balance")
    }
}
