import Foundation

// MARK: - Models

struct TokenResponse: Decodable {
    let id: String
    let mintAddress: String
    let name: String
    let symbol: String
    let supply: UInt64
    let decimals: UInt8
    let createdAt: String
}

// MARK: - TokensController

private let tokensBase = "/tokens"

extension APIClient {
    func listAllTokens() async throws -> [TokenResponse] {
        try await get(tokensBase)
    }

    func createToken(name: String, symbol: String, supply: UInt64, imageData: Data) async throws -> TokenResponse {
        guard accessToken != nil else {
            throw APIError.serverError("You must be logged in to create a token.")
        }
        return try await multipart(
            tokensBase,
            fields: ["name": name, "symbol": symbol, "supply": String(supply)],
            imageData: imageData,
            imageMimeType: "image/jpeg"
        )
    }
}

// MARK: - WalletController

private let walletBase = "/wallet"

extension APIClient {
    func listWalletTokens() async throws -> [TokenResponse] {
        try await get("\(walletBase)/tokens")
    }
}
