import SwiftUI

// MARK: - LoginView

struct LoginView: View {
    @Environment(AuthSession.self) private var authSession
    @Binding var showRegister: Bool

    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorText = ""

    var body: some View {
        VStack(spacing: 16) {
            Text("Welcome back")
                .font(.largeTitle.bold())
                .foregroundColor(.white)

            TextField(
                "",
                text: $email,
                prompt: Text("Email").foregroundColor(AppColors.secondaryTextColor)
            )
            .textContentType(.emailAddress)
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .padding()
            .background(AppColors.charcoalColor)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .foregroundColor(.white)

            SecureField(
                "",
                text: $password,
                prompt: Text("Password").foregroundColor(AppColors.secondaryTextColor)
            )
            .textContentType(.oneTimeCode)
            .padding()
            .background(AppColors.charcoalColor)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .foregroundColor(.white)

            if !errorText.isEmpty {
                Text(errorText)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
            }

            Button { submit() } label: {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(AppColors.goldColor)
            .disabled(email.isEmpty || password.isEmpty || isLoading)

            Button("Create an account") {
                showRegister = true
                errorText = ""
            }
            .foregroundColor(AppColors.goldColor)
            .padding(.top, 8)
        }
        .padding()
    }

    // MARK: - Private

    @MainActor
    private func submit() {
        errorText = ""
        isLoading = true
        Task {
            defer { isLoading = false }
            do {
                let response = try await APIClient.shared.login(
                    email: email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
                    password: password.trimmingCharacters(in: .whitespacesAndNewlines)
                )
                authSession.apply(response)
            } catch {
                errorText = error.localizedDescription
            }
        }
    }
}
