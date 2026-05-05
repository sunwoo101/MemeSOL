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
    // List all tokens that were created using this app by any user.
    func listAllTokens() async throws -> [TokenResponse] {
        guard accessToken != nil else {
            throw APIError.serverError("You must be logged in to list tokens.")
        }
        return try await get(tokensBase)
    }

    // Creates a new token and adds it to the wallet.
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
