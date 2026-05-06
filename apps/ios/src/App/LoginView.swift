import SwiftUI

struct LoginView: View {
    @Environment(AuthSession.self) private var authSession
    @Binding var showRegister: Bool

    @State private var email = ""
    @State private var password = ""

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
                .textContentType(.password)
                .padding()
                .background(AppColors.charcoalColor)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .foregroundColor(.white)

            if !authSession.errorMessage.isEmpty {
                Text(authSession.errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
            }

            Button {
                Task { await authSession.login(email: email, password: password) }
            } label: {
                if authSession.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(AppColors.goldColor)
            .disabled(email.isEmpty || password.isEmpty || authSession.isLoading)

            Button("Create an account") {
                showRegister = true
                authSession.errorMessage = ""
            }
            .foregroundColor(AppColors.goldColor)
            .padding(.top, 8)
        }
        .padding()
    }
}
