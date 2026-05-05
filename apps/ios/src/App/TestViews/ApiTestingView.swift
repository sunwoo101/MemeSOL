import SwiftUI
import PhotosUI

// MARK: - ApiTestingView

struct ApiTestingView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("API Testing")
                    .font(.largeTitle)
                    .bold()

                AuthSectionView()
                TokensSectionView()
                ListAllTokensSectionView()
                ListWalletTokensSectionView()
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

// MARK: - TokensSectionView

private struct TokensSectionView: View {
    @State private var name = ""
    @State private var symbol = ""
    @State private var supply = ""
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    @State private var isLoading = false
    @State private var tokenResponse: TokenResponse? = nil
    @State private var testedEndpoint = ""
    @State private var errorText = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tokens")
                .font(.title2)
                .bold()

            VStack(spacing: 12) {
                TextField("Name", text: $name)
                TextField("Symbol", text: $symbol)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.characters)
                TextField("Supply", text: $supply)
                    .keyboardType(.numberPad)
            }
            .textFieldStyle(.roundedBorder)

            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                Label(selectedImageData == nil ? "Select Image" : "Image Selected", systemImage: "photo")
            }
            .onChange(of: selectedPhotoItem) { _, newItem in
                Task {
                    selectedImageData = nil
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        selectedImageData = uiImage.jpegData(compressionQuality: 0.8)
                    }
                }
            }

            Button("Create Token") { submit() }
                .buttonStyle(.borderedProminent)
                .disabled(isLoading || name.isEmpty || symbol.isEmpty || UInt64(supply) == nil || selectedImageData == nil)

            if isLoading {
                ProgressView()
            }

            if let response = tokenResponse {
                ResponseCard(endpoint: testedEndpoint) {
                    ResponseRow(label: "Mint Address", value: response.mintAddress)
                    ResponseRow(label: "Name", value: response.name)
                    ResponseRow(label: "Symbol", value: response.symbol)
                    ResponseRow(label: "Supply", value: String(response.supply))
                    ResponseRow(label: "Decimals", value: String(response.decimals))
                }
            }

            APIErrorView(message: errorText)
        }
    }

    @MainActor
    private func submit() {
        guard let imageData = selectedImageData, let supplyValue = UInt64(supply) else { return }

        isLoading = true
        Task {
            defer { isLoading = false }
            do {
                testedEndpoint = "POST /api/tokens"
                tokenResponse = try await APIClient.shared.createToken(
                    name: name,
                    symbol: symbol,
                    supply: supplyValue,
                    imageData: imageData
                )
                errorText = ""
            } catch {
                tokenResponse = nil
                errorText = error.localizedDescription
            }
        }
    }
}

// MARK: - ListAllTokensSectionView

private struct ListAllTokensSectionView: View {
    @State private var isLoading = false
    @State private var tokens: [TokenResponse] = []
    @State private var hasLoaded = false
    @State private var errorText = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("All Tokens")
                .font(.title2)
                .bold()

            Button("GET /tokens") { submit() }
                .buttonStyle(.bordered)
                .disabled(isLoading)

            if isLoading {
                ProgressView()
            }

            if hasLoaded {
                ResponseCard(endpoint: "GET /api/tokens") {
                    if tokens.isEmpty {
                        Text("No tokens")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(tokens, id: \.id) { token in
                            TokenListRow(token: token)
                        }
                    }
                }
            }

            APIErrorView(message: errorText)
        }
    }

    @MainActor
    private func submit() {
        isLoading = true
        Task {
            defer { isLoading = false }
            do {
                tokens = try await APIClient.shared.listAllTokens()
                hasLoaded = true
                errorText = ""
            } catch {
                tokens = []
                errorText = error.localizedDescription
            }
        }
    }
}

// MARK: - ListWalletTokensSectionView

private struct ListWalletTokensSectionView: View {
    @State private var isLoading = false
    @State private var tokens: [TokenResponse] = []
    @State private var hasLoaded = false
    @State private var errorText = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Wallet Tokens")
                .font(.title2)
                .bold()

            Button("GET /wallet/tokens") { submit() }
                .buttonStyle(.bordered)
                .disabled(isLoading)

            if isLoading {
                ProgressView()
            }

            if hasLoaded {
                ResponseCard(endpoint: "GET /api/wallet/tokens") {
                    if tokens.isEmpty {
                        Text("No tokens")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(tokens, id: \.id) { token in
                            TokenListRow(token: token)
                        }
                    }
                }
            }

            APIErrorView(message: errorText)
        }
    }

    @MainActor
    private func submit() {
        isLoading = true
        Task {
            defer { isLoading = false }
            do {
                tokens = try await APIClient.shared.listWalletTokens()
                hasLoaded = true
                errorText = ""
            } catch {
                tokens = []
                errorText = error.localizedDescription
            }
        }
    }
}

// MARK: - TokenListRow

private struct TokenListRow: View {
    let token: TokenResponse

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(token.name) (\(token.symbol))")
                .font(.footnote)
                .bold()
            ResponseRow(label: "Mint Address", value: token.mintAddress)
            ResponseRow(label: "Supply", value: String(token.supply))
        }
        .padding(.vertical, 4)
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
