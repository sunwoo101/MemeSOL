//
//  TokenDetailsViewModel.swift
//  App
//
//  Created by Gurpreet on 8/5/2026.
//

import Foundation
import Combine

class TokenDetailsViewModel : ObservableObject {
    @Published var walletToken : WalletTokenResponse?
    @Published var transactions: [TransactionHistoryResponse] = []
    
    @Published var isInWallet: Bool = false
    
    @Published var errorMessage = ""
    
    func loadWalletData (mintAddress: String) async {
        
        do {
            let walletTokens = try await APIClient.shared.listWalletTokens()
            
            walletToken = walletTokens.first {
                $0.mintAddress == mintAddress
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func loadTransactionData (mintAddress: String) async {
        do {
           _ = try await APIClient.shared.getTransactions(mintAddress: mintAddress)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func checkIfInWallet (mintAddress: String) async {
        do {
            let walletTokens = try await APIClient.shared.listWalletTokens()
            
            isInWallet = walletTokens.contains {
                $0.mintAddress == mintAddress
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    
}
