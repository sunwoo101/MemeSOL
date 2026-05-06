import Foundation
import Observation

// MARK: - AuthSession

@Observable
@MainActor
final class AuthSession {
    private(set) var isAuthenticated: Bool
    private(set) var accessToken = ""
    private(set) var walletPublicKey = ""

    init() {
        isAuthenticated = APIClient.shared.accessToken != nil
    }

    func apply(_ response: AuthResponse) {
        accessToken = response.accessToken
        walletPublicKey = response.walletPublicKey
        isAuthenticated = true
    }

    func logout() {
        APIClient.shared.clearTokens()
        isAuthenticated = false
        accessToken = ""
        walletPublicKey = ""
    }
}
