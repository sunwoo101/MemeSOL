import Foundation

// MARK: - Models

struct SendTokenResponse: Decodable {
    let signature: String
}

struct TokenResponse: Decodable {
    let id: String
    let mintAddress: String
    let name: String
    let symbol: String
    let supply: UInt64
    let decimals: UInt8
    let createdAt: String
}

struct TokenListResponse: Decodable {
    let id: String
    let mintAddress: String
    let name: String
    let symbol: String
    let imgUrl: String
    let price: Double
    let gainsPercent: Double
}

// MARK: - TokensController

private let tokensBase = "/tokens"

extension APIClient {
    // List all tokens that were created using this app by any user.
    func listAllTokens() async throws -> [TokenListResponse] {
        guard accessToken != nil else {
            throw APIError.serverError("You must be logged in to list tokens.")
        }
        return try await get(tokensBase)
    }

    // Transfers tokens to a recipient address. Amount is the amount of the token (not $).
    func sendToken(mintAddress: String, recipientAddress: String, amount: Decimal) async throws -> SendTokenResponse {
        guard accessToken != nil else {
            throw APIError.serverError("You must be logged in to send tokens.")
        }
        guard amount > 0 else {
            throw APIError.serverError("Amount must be greater than zero.")
        }
        struct Body: Encodable { let recipientAddress: String; let amount: Decimal }
        return try await post("\(tokensBase)/\(mintAddress)/send", body: Body(recipientAddress: recipientAddress, amount: amount))
    }

    // Creates a new token and adds it to the wallet.
    func createToken(name: String, symbol: String, supply: UInt64, imageData: Data? = nil, imFeelingLucky: Bool = false) async throws -> TokenResponse {
        guard accessToken != nil else {
            throw APIError.serverError("You must be logged in to create a token.")
        }
        return try await multipart(
            tokensBase,
            fields: ["name": name, "symbol": symbol, "supply": String(supply), "imFeelingLucky": String(imFeelingLucky)],
            imageData: imageData,
            imageMimeType: imageData != nil ? "image/jpeg" : nil
        )
    }
}
