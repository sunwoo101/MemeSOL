//
//  ReceiveView.swift
//  
//
//  Created by Gurpreet on 3/5/2026.
//

import SwiftUI

struct ReceiveView: View {
    @StateObject var viewModel = ReceiveViewModel()
    
    var body: some View {
        Text(viewModel.address)
    }
}

#Preview {
    ReceiveView()
}

//show wallet address
//show qr
//copy button
//share?
