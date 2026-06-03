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
        walletPublicKey = KeychainHelper.load(forKey: "walletPublicKey") ?? ""
    }
    
    func apply(_ response: AuthResponse) {
        accessToken = response.accessToken
        walletPublicKey = response.walletPublicKey
        KeychainHelper.save(response.walletPublicKey, forKey: "walletPublicKey")
        isAuthenticated = true
    }
    
    func logout() {
        APIClient.shared.clearTokens()
        KeychainHelper.delete(forKey: "walletPublicKey")
        isAuthenticated = false
        accessToken = ""
        walletPublicKey = ""
    }
}
