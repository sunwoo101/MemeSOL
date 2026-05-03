//
//  ReceiveViewModel.swift
//  
//
//  Created by Gurpreet on 3/5/2026.
//

//give wallet address to view
//handle copy
//prepare  qr
//communicate w service 

class ReceiveViewModel: ObservableObject {
    @Published var address: String
    
    init() {
        self.address = WalletService().getWalletAddress().address
    }    
}
