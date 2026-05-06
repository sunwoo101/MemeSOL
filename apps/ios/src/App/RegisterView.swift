import SwiftUI

struct RegisterView: View {
    @Environment(AuthSession.self) private var authSession
    @Binding var showRegister: Bool

    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var localError = ""

    var body: some View {
        VStack(spacing: 16) {
            Text("Create account")
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
                .textContentType(.password)
                .padding()
                .background(AppColors.charcoalColor)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .foregroundColor(.white)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

            VStack(alignment: .leading, spacing: 6) {
                ProgressView(value: passwordStrengthScore, total: 1.0)
                    .tint(passwordStrengthColor)
                Text(passwordStrengthLabel)
                    .font(.caption)
                    .foregroundColor(passwordStrengthColor)
            }

            SecureField(
                "",
                text: $confirmPassword,
                prompt: Text("Confirm password").foregroundColor(AppColors.secondaryTextColor)
            )
                .textContentType(.password)
                .padding()
                .background(AppColors.charcoalColor)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .foregroundColor(.white)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

            if !localError.isEmpty {
                Text(localError)
                    .foregroundColor(.red)
                    .font(.footnote)
            } else if !authSession.errorMessage.isEmpty {
                Text(authSession.errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
            }

            Button {
                localError = ""
                guard password.count >= 8 else {
                    localError = "Password must be at least 8 characters."
                    return
                }
                guard password == confirmPassword else {
                    localError = "Passwords do not match."
                    return
                }
                Task { await authSession.register(email: email, password: password) }
            } label: {
                if authSession.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Register")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(AppColors.goldColor)
            .disabled(email.isEmpty || password.isEmpty || confirmPassword.isEmpty || authSession.isLoading)

            Button("Already have an account? Login") {
                showRegister = false
                localError = ""
                authSession.errorMessage = ""
            }
            .foregroundColor(AppColors.goldColor)
            .padding(.top, 8)
        }
        .padding()
    }

    private var passwordStrengthScore: Double {
        var score = 0.0
        if password.count >= 8 { score += 0.35 }
        if password.rangeOfCharacter(from: .uppercaseLetters) != nil { score += 0.2 }
        if password.rangeOfCharacter(from: .decimalDigits) != nil { score += 0.2 }
        if password.rangeOfCharacter(from: CharacterSet.punctuationCharacters.union(.symbols)) != nil { score += 0.25 }
        return min(score, 1.0)
    }

    private var passwordStrengthLabel: String {
        switch passwordStrengthScore {
        case 0..<0.35: return "Weak password"
        case 0.35..<0.7: return "Medium password"
        default: return "Strong password"
        }
    }

    private var passwordStrengthColor: Color {
        switch passwordStrengthScore {
        case 0..<0.35: return .red
        case 0.35..<0.7: return .orange
        default: return .green
        }
    }
}
