//
//  Main.swift
//  Assignment3
//
//  Created by Sun Woo Kim on 24/4/2026.
//

import SwiftUI

@main
struct Main: App {
    @State private var authSession = AuthSession()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authSession)
        }
    }
}
