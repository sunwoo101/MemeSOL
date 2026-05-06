//
//  SendView.swift
//  App
//
//  Created by Gurpreet on 6/5/2026.
//

import SwiftUI

struct SendView: View {
    @State var address = ""
    @State var amount = ""
    @State var selectedToken = ""
    
    
    var body: some View {
        ZStack {
            AppColors.blackColor.ignoresSafeArea()
            
            VStack (spacing: 20) {
                Text("Send")
                    .font(.title2.bold())
                    .foregroundColor(AppColors.goldColor)
                    .padding(.top, 10)
                
                VStack (alignment: .leading, spacing: 16) {
                    Text("Recipient Address")
                        .foregroundColor(.white)
                        .font(.headline)
                    
                    HStack {
                        TextField("Enter or scan wallet address", text: $address, axis: .vertical)
                            .foregroundColor(.white)
                            
                        
                        Spacer()
                        
                        Divider()
                                .frame(height: 45)
                                .background(Color.white.opacity(0.9))
                        
                        Button (action: {
                            //do scan address
                        }) {
                            VStack(spacing: 5) {
                                Image(systemName: "qrcode.viewfinder")
                                Text("Scan")
                                    .font(.system(size:12))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 5)
                        }
                    }
                    .padding()
                    .background(AppColors.charcoalColor)
                    .cornerRadius(SharedLayout.cornerRadius)
                    
                }
                Spacer()
            }
            .padding(.horizontal, 10)
        }
    }
}

#Preview {
    SendView()
}
