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
    
    @Published private(set) var favourites: Set<String> = []
    
    let key = "favourite_tokens"
    
    @Published var isInWallet: Bool = false
    
    @Published var errorMessage = ""
    
    init() {
        loadFavourites()
    }
    
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
            transactions = try await APIClient.shared.getTransactions(mintAddress: mintAddress)
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
    
    func isFavourite(_ mintAddress: String) -> Bool {
        favourites.contains(mintAddress)
    }
    
    func toggleFavourite(_ mintAddress: String) {
        if favourites.contains(mintAddress) {
            favourites.remove(mintAddress)
        } else {
            favourites.insert(mintAddress)
        }
        saveFavourites()
    }
    
    private func saveFavourites() {
        UserDefaults.standard.set(Array(favourites), forKey: key)
    }
    
    private func loadFavourites() {
        let saved = UserDefaults.standard.stringArray(forKey: key) ?? []
        favourites = Set(saved)
    }
}
