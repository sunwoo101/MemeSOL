//
//  BuyViewModel.swift
//  App
//
//  Created by Gurpreet on 9/5/2026.
//

import SwiftUI
import Combine 

class BuyViewModel : ObservableObject {
    @Published var tokens: [TokenListResponse] = []
    @Published var walletToken: WalletTokenResponse?
    
    @Published var isBuying = false

    @Published var errorMessage = ""
    
    @Published var searchText = ""
    
    var filteredTokens: [TokenListResponse] {
        if searchText.isEmpty {
            return tokens
        }

        return tokens.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
            ||
            $0.symbol.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    func loadTokens() async {
        do {
            tokens = try await APIClient.shared.listAllTokens()
        } catch {
            errorMessage = error.localizedDescription
            print(error)
        }
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
    
}
