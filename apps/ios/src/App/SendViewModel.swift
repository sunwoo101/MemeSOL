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
    
    //get user's tokens
    func loadTokens() async {
        do {
            walletTokens = try await APIClient.shared.listWalletTokens()
        } catch {
            errorMessage = error.localizedDescription
            print(error)
        }
    }
    
    //check if the user has enough crypto for the transaction 
    func isTransactionValid(balance: Double?, amount: Decimal?) -> Bool {
        guard let balance, let amount, amount > 0 else {
            return false
        }
        return Decimal(balance) >= amount 
    }
}
