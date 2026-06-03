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
    
    @Published var isSending = false
    @Published var sendError = ""
    @Published var sendSuccess = false
    
    //get user's tokens
    func loadTokens() async {
        do {
            walletTokens = try await APIClient.shared.listWalletTokens()
        } catch {
            errorMessage = error.localizedDescription
            print(error)
        }
    }
    
    func sendToken(mintAddress: String, recipientAddress: String, amount: Decimal) async {
        isSending = true
        sendError = ""
        
        do {
            _ = try await APIClient.shared.sendToken(mintAddress: mintAddress,
                                                     recipientAddress: recipientAddress,
                                                     amount: amount)
            await loadTokens()
            sendSuccess = true
        } catch {
            sendError = error.localizedDescription
        }
        
        isSending = false
    }
    
    //check if the user has enough crypto for the transaction 
    func isTransactionValid(balance: Double?, amount: Decimal?) -> Bool {
        guard let balance, let amount, amount > 0 else {
            return false
        }
        return Decimal(balance) >= amount 
    }
}
