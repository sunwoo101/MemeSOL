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
            DashboardView()
        } else {
            OnboardingView()
        }
    }
}

#Preview {
    ContentView()
        .environment(AuthSession())
}
