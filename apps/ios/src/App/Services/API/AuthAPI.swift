import Foundation

// MARK: - Models

struct AuthResponse: Decodable {
    let accessToken: String
    let walletPublicKey: String
    let refreshToken: String
}

// MARK: - AuthController

private let authBase = "/auth"

extension APIClient {
    // Registers a user then returns accessToken, walletPublicKey, and refreshToken. Tokens are persisted to Keychain.
    func register(email: String, password: String) async throws -> AuthResponse {
        struct Body: Encodable { let email: String; let password: String }
        let response: AuthResponse = try await post("\(authBase)/register", body: Body(email: email, password: password))
        persistTokens(accessToken: response.accessToken, refreshToken: response.refreshToken)
        return response
    }

    // Logs in a user then returns accessToken, walletPublicKey, and refreshToken. Tokens are persisted to Keychain.
    func login(email: String, password: String) async throws -> AuthResponse {
        struct Body: Encodable { let email: String; let password: String }
        let response: AuthResponse = try await post("\(authBase)/login", body: Body(email: email, password: password))
        persistTokens(accessToken: response.accessToken, refreshToken: response.refreshToken)
        return response
    }
}
