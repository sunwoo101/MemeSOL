import SwiftUI

// MARK: - ApiTestingView

struct ApiTestingView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("API Testing")
                    .font(.largeTitle)
                    .bold()

                AuthSectionView()
            }
            .padding()
        }
    }
}

// MARK: - AuthSectionView

private struct AuthSectionView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var authResponse: AuthResponse? = nil
    @State private var testedEndpoint = ""
    @State private var errorText = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Auth")
                .font(.title2)
                .bold()

            VStack(spacing: 12) {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                SecureField("Password", text: $password)
            }
            .textFieldStyle(.roundedBorder)

            HStack(spacing: 12) {
                Button("Register") { submit(action: .register) }
                    .buttonStyle(.borderedProminent)
                Button("Login") { submit(action: .login) }
                    .buttonStyle(.bordered)
            }
            .disabled(isLoading || email.isEmpty || password.isEmpty)

            if isLoading {
                ProgressView()
            }

            if let response = authResponse {
                ResponseCard(endpoint: testedEndpoint) {
                    ResponseRow(label: "Wallet", value: response.walletPublicKey)
                    ResponseRow(label: "Access Token", value: response.accessToken)
                    ResponseRow(label: "Refresh Token", value: response.refreshToken)
                }
            }

            APIErrorView(message: errorText)
        }
    }

    private enum AuthAction { case register, login }

    @MainActor
    private func submit(action: AuthAction) {
        isLoading = true
        Task {
            defer { isLoading = false }
            do {
                switch action {
                case .register:
                    testedEndpoint = "POST /api/auth/register"
                    authResponse = try await APIClient.shared.register(email: email, password: password)
                case .login:
                    testedEndpoint = "POST /api/auth/login"
                    authResponse = try await APIClient.shared.login(email: email, password: password)
                }
                errorText = ""
            } catch {
                authResponse = nil
                errorText = error.localizedDescription
            }
        }
    }
}

// MARK: - ResponseCard

private struct ResponseCard<Content: View>: View {
    let endpoint: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(endpoint)
                .font(.caption)
                .foregroundStyle(.secondary)
                .monospaced()
            content()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - ResponseRow

private struct ResponseRow: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.footnote)
                .monospaced()
                .lineLimit(2)
                .truncationMode(.middle)
        }
    }
}

// MARK: - APIErrorView

private struct APIErrorView: View {
    let message: String

    var body: some View {
        if !message.isEmpty {
            Text(message)
                .foregroundStyle(.red)
                .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    ApiTestingView()
}
