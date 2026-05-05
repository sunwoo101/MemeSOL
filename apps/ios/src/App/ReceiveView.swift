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
        ZStack {
            AppColors.blackColor.ignoresSafeArea()
            
            VStack {
                Text("Receive")
                    .font(.title2.bold())
                    .foregroundColor(AppColors.goldColor)
                    .padding(.top, 10)
                
                GeometryReader { geometry in
                    VStack{
                        if let qrImage = viewModel.qrImage {
                            Image(uiImage: qrImage)
                                .resizable()
                                .interpolation(.none)
                                .scaledToFit()
                                .frame(width: min(geometry.size.width, geometry.size.height) * 0.45)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Your Address")
                        .foregroundStyle(.white)
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    HStack {
                        Text(viewModel.address)
                            .foregroundColor(.white)
                            .font(.system(size: 14, design: .monospaced))
                            .lineLimit(1)
                            .truncationMode(.middle)
                        
                        Spacer()
                        
                        Divider()
                                .frame(height: 40)
                                .background(Color.white.opacity(0.9))
                        
                        Button (action: {
                            viewModel.copyAddress()
                        }) {
                            VStack(spacing: 5) {
                                Image(systemName: "doc.on.doc")
                                Text(viewModel.copyButtonText)
                                    .font(.system(size:12))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 5)
                        }
                    }
                    .padding()
                    .background(AppColors.charcoalColor)
                    .cornerRadius(AppLayout.cornerRadius)
                    
                    Spacer()
                    
                }
            }
            .padding(.horizontal, 15)
        }
    }
}

#Preview {
    ReceiveView()
}
