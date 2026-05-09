//
//  BuyTokenView.swift
//  App
//
//  Created by Gurpreet on 9/5/2026.
//

import SwiftUI

struct BuyTokenView: View {
    let token: TokenListResponse
    
    @StateObject private var viewModel = BuyViewModel()
    
    @State private var amount = ""
    
    var body: some View {
        ZStack {
            AppColors.blackColor.ignoresSafeArea()
            
            ScrollView {
                VStack (spacing: 24) {
                    
                    VStack (spacing: 16) {
                        AsyncImage(url: URL(string: token.imgUrl)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder : {
                            Circle().fill(AppColors.charcoalColor)
                        }
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        
                        VStack (spacing: 6) {
                            Text(token.name)
                                .font(.title.bold())
                                .foregroundColor(.white)
                            
                            Text(token.symbol)
                                .foregroundColor(AppColors.secondaryTextColor)
                            
                            Text("$\(token.price, specifier: "%.2f")")
                                .font(.title3.bold())
                                .foregroundColor(AppColors.goldColor)
                            
                            Text(token.gainsPercent > 0 ? ("+\(token.gainsPercent, specifier: "%.2f")%") : ("-\(token.gainsPercent, specifier: "%.2f")%"))
                                .foregroundColor(token.gainsPercent > 0 ? .green : .red)
                        }
                        
                        VStack (spacing: 8) {
                            Text("Your Balance")
                                .foregroundColor(AppColors.secondaryTextColor)
                            
                            Text("\(viewModel.walletToken?.balance ?? 0, specifier: "%.2f") \(token.symbol)")
                                .font(.title.bold())
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.charcoalColor)
                        .cornerRadius(20)
                        
                        
                        VStack (alignment: .leading) {
                            Text("Amount")
                                .foregroundColor(.white)
                                .font(.headline)
                            
                            HStack {
                                    TextField(
                                        "",
                                        text: $amount,
                                        prompt: Text("0.00").foregroundColor(AppColors.secondaryTextColor)
                                    )
                                    .keyboardType(.decimalPad)
                                    .font(.system(size: 30, weight: .semibold))
                                    .foregroundColor(.white)
                                    .onChange(of: amount) {
                                        let filtered = amount.filter { "0123456789.".contains($0)
                                        }
                                        
                                        let dotCount = filtered.filter { $0 == "."}.count
                                        
                                        if dotCount > 1 {
                                            if let firstDot = filtered.firstIndex(of: ".") {
                                                var cleaned = filtered
                                                cleaned.remove(at: firstDot)
                                                
                                                amount = cleaned
                                            }
                                        } else {
                                            amount = filtered
                                        }
                                    }
                                
                                Text(token.symbol)
                                        .foregroundColor(AppColors.secondaryTextColor)
                                        .font(.headline)
                                }
                        }
                        .padding()
                        .background(AppColors.charcoalColor)
                        .cornerRadius(SharedLayout.cornerRadius)

                        Button {
                            //confirm modal
                        } label: {
                            Text("Buy \(token.symbol)")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppColors.goldColor)
                                .foregroundColor(.black)
                                .cornerRadius(SharedLayout.cornerRadius)
                        }
                    }
                }
                
            }
            
        }
    }
}



#Preview {
    BuyTokenView(token: TokenListResponse(id: "1", mintAddress: "ahifh1i1fiwq13", name: "Bitcoin", symbol: "BTC", imgUrl: "", price: 121.1, gainsPercent: 2.4))
}
