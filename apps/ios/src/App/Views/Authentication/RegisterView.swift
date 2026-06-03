import SwiftUI

// MARK: - RegisterView

struct RegisterView: View {
    @Environment(AuthSession.self) private var authSession
    @Binding var showRegister: Bool
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorText = ""
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Create account")
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
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            
            SecureField(
                "",
                text: $confirmPassword,
                prompt: Text("Confirm password").foregroundColor(AppColors.secondaryText)
            )
            .textContentType(.oneTimeCode)
            .padding()
            .background(AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .foregroundColor(AppColors.ink)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            
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
                    Text("Register")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(AppColors.accent)
            .disabled(email.isEmpty || password.isEmpty || confirmPassword.isEmpty || isLoading)
            
            Button("Already have an account? Login") {
                showRegister = false
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
        guard password.count >= 8 else {
            errorText = "Password must be at least 8 characters."
            return
        }
        guard password.range(of: "[A-Z]", options: .regularExpression) != nil else {
            errorText = "Password must contain at least one uppercase letter."
            return
        }
        guard password.range(of: "[0-9]", options: .regularExpression) != nil else {
            errorText = "Password must contain at least one digit."
            return
        }
        guard password.range(of: "[^a-zA-Z0-9]", options: .regularExpression) != nil else {
            errorText = "Password must contain at least one special character."
            return
        }
        guard password == confirmPassword else {
            errorText = "Passwords do not match."
            return
        }
        isLoading = true
        Task {
            defer { isLoading = false }
            do {
                let response = try await APIClient.shared.register(
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
