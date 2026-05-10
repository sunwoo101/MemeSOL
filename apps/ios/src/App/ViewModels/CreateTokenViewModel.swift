//
//  CreateTokenViewModel.swift
//  App
//
//  Created by Gurpreet on 8/5/2026.
//

import Foundation
import Combine

class CreateTokenViewModel : ObservableObject {
    @Published var isCreating = false
    @Published var errorMessage = ""
    @Published var creationSuccess = false
    
    func createToken(name: String, symbol: String, supply: UInt64, image: Data) async {
        isCreating = true
        errorMessage = ""
        
        do {
            _ = try await APIClient.shared.createToken(name: name, symbol: symbol, supply: supply, imageData: image)
            creationSuccess = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isCreating = false
    }
    
}
