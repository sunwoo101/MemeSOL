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
    // Registers a user then returns accessToken, walletPublicKey, and refreshToken. Access token is stored in APIClient for future requests.
    func register(email: String, password: String) async throws -> AuthResponse {
        struct Body: Encodable { let email: String; let password: String }
        let response: AuthResponse = try await post("\(authBase)/register", body: Body(email: email, password: password))
        accessToken = response.accessToken
        return response
    }

    // Logs in a user then returns accessToken, walletPublicKey, and refreshToken. Access token is stored in APIClient for future requests.
    func login(email: String, password: String) async throws -> AuthResponse {
        struct Body: Encodable { let email: String; let password: String }
        let response: AuthResponse = try await post("\(authBase)/login", body: Body(email: email, password: password))
        accessToken = response.accessToken
        return response
    }
}
