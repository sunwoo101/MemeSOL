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
                .foregroundColor(AppColors.ink)

            TextField(
                "",
                text: $email,
                prompt: Text("Email").foregroundColor(AppColors.secondaryText)
            )
            .textContentType(.emailAddress)
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .padding()
            .background(AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .foregroundColor(AppColors.ink)

            SecureField(
                "",
                text: $password,
                prompt: Text("Password").foregroundColor(AppColors.secondaryText)
            )
            .textContentType(.oneTimeCode)
            .padding()
            .background(AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .foregroundColor(AppColors.ink)

            if !errorText.isEmpty {
                Text(errorText)
                    .foregroundColor(AppColors.error)
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
            .tint(AppColors.accent)
            .disabled(email.isEmpty || password.isEmpty || isLoading)

            Button("Create an account") {
                showRegister = true
                errorText = ""
            }
            .foregroundColor(AppColors.accent)
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
