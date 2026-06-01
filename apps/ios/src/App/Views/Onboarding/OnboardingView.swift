import SwiftUI

struct OnboardingView: View {
    @State private var showRegister = false

    var body: some View {
        ZStack {
            AppColors.canvas.ignoresSafeArea()
            if showRegister {
                RegisterView(showRegister: $showRegister)
            } else {
                LoginView(showRegister: $showRegister)
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    OnboardingView()
        .environment(AuthSession())
}
