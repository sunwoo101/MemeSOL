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
    @Environment(AuthSession.self) private var authSession
    
    
    var body: some View {
        ZStack {
            AppColors.canvas.ignoresSafeArea()
            
            VStack {
                Text("Receive")
                    .font(.title2.bold())
                    .foregroundColor(AppColors.accent)
                    .padding(.top, 10)
                
                GeometryReader { geometry in
                    VStack{
                        if let qrImage = viewModel.qrImage {
                            Image(uiImage: qrImage)
                                .resizable()
                                .interpolation(.none)
                                .scaledToFit()
                                .frame(width: min(geometry.size.width, geometry.size.height) * 0.65)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Your Address")
                        .foregroundStyle(AppColors.ink)
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    HStack {
                        Text(authSession.walletPublicKey)
                            .foregroundColor(AppColors.ink)
                            .font(.system(size: 14, design: .monospaced))
                            .lineLimit(1)
                            .truncationMode(.middle)
                        
                        Spacer()
                        
                        Divider()
                            .frame(height: 40)
                            .background(AppColors.ink.opacity(0.3))
                        
                        Button (action: {
                            viewModel.copyAddress(authSession.walletPublicKey)
                        }) {
                            VStack(spacing: 5) {
                                Image(systemName: "doc.on.doc")
                                Text(viewModel.copyButtonText)
                                    .font(.system(size:12))
                            }
                            .foregroundColor(AppColors.ink)
                            .padding(.horizontal, 5)
                        }
                    }
                    .padding()
                    .background(AppColors.surface)
                    .cornerRadius(SharedLayout.cornerRadius)
                    
                    Spacer()
                    
                }
            }
            .padding(.horizontal, 15)
        }
        .onAppear {
            viewModel.updateQRCode(from: authSession.walletPublicKey)
        }
        .onChange(of: authSession.walletPublicKey) { newAddress in
            viewModel.updateQRCode(from: newAddress)
        }
    }
}

#Preview {
    ReceiveView().environment(AuthSession())
}
