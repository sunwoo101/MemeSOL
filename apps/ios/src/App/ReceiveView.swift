//
//  ReceiveView.swift
//  
//
//  Created by Gurpreet on 3/5/2026.
//

import SwiftUI
import UIKit


struct ReceiveView: View {
    @StateObject var viewModel = ReceiveViewModel()
    
    var body: some View {
        Text(viewModel.address)
        
        if let qrImage = viewModel.qrImage {
            Image(uiImage: qrImage)
                .resizable()
                .interpolation(.none)
                .scaledToFit()
                .frame(width: 200, height: 200)
        }
        HStack {
            Button {
                viewModel.copyAddress()
            } label: {
                Label(viewModel.copyButtonText, systemImage: "doc.on.doc")
            }
        }
        
    }
}

#Preview {
    ReceiveView()
}
