import Foundation
import Observation

@Observable
@MainActor
final class AuthSession {
    private(set) var isAuthenticated = false
    private(set) var isLoading = false
    var errorMessage = ""

    /// Memory-only JWT token.
    private(set) var accessToken = ""
    /// Public wallet address returned by backend.
    private(set) var walletPublicKey = ""

    func login(email: String, password: String) async {
        let cleanedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let cleanedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        await performAuth {
            try await APIClient.shared.login(email: cleanedEmail, password: cleanedPassword)
        }
    }

    func register(email: String, password: String) async {
        let cleanedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let cleanedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        await performAuth {
            try await APIClient.shared.register(email: cleanedEmail, password: cleanedPassword)
        }
    }

    func logout() {
        isAuthenticated = false
        accessToken = ""
        walletPublicKey = ""
        errorMessage = ""
    }

    private func performAuth(request: () async throws -> AuthResponse) async {
        isLoading = true
        defer { isLoading = false }
        do {
            let response = try await request()
            accessToken = response.accessToken
            walletPublicKey = response.walletPublicKey
            isAuthenticated = true
            errorMessage = ""
        } catch {
            isAuthenticated = false
            errorMessage = error.localizedDescription
        }
    }
}
