//
//  SendViewModel.swift
//  App
//
//  Created by Gurpreet on 6/5/2026.
//

import Foundation
import Combine


class SendViewModel: ObservableObject {
    @Published var walletTokens: [WalletTokenResponse] = []
    @Published var errorMessage = ""
    
    func loadTokens() async {
        do {
            walletTokens = try await APIClient.shared.listWalletTokens()
        } catch {
            errorMessage = error.localizedDescription
            print(error)
        }
    }
}
