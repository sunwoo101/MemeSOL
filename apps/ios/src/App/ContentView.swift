//
//  ContentView.swift
//  Assignment3
//
//  Created by Sun Woo Kim on 24/4/2026.
//

import SwiftUI

struct ContentView: View {
    @Environment(AuthSession.self) private var authSession

    var body: some View {
        if authSession.isAuthenticated {
            VStack(spacing: 0) {
                HStack {
                    Text(authSession.walletPublicKey)
                        .font(.caption2.monospaced())
                        .foregroundColor(AppColors.secondaryTextColor)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    Spacer()
                    Button("Logout") {
                        authSession.logout()
                    }
                    .font(.caption.bold())
                    .foregroundColor(AppColors.goldColor)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 8)
                .background(AppColors.blackColor)

                DashboardView()
            }
            .background(AppColors.blackColor.ignoresSafeArea())
        } else {
            OnboardingView()
        }
    }
}

#Preview {
    ContentView()
        .environment(AuthSession())
}
