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
    @Published var errorMessage = ""
    
    func loadTokens() async {
        do {
            tokens = try await APIClient.shared.listAllTokens()
        } catch {
            errorMessage = error.localizedDescription
            print(error)
        }
    }
    
}
