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
    
    @State private var showingConfirmModal: Bool = false
    
    @Environment(\.dismiss) private var dismiss
    
    
    var body: some View {
        ZStack {
            AppColors.canvas.ignoresSafeArea()
            
            ScrollView {
                VStack (spacing: 24) {
                    
                    VStack (spacing: 16) {
                        AsyncImage(url: URL(string: token.imgUrl)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder : {
                            Circle().fill(AppColors.surface)
                        }
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        
                        VStack (spacing: 6) {
                            Text(token.name)
                                .font(.title.bold())
                                .foregroundColor(AppColors.ink)
                            
                            Text(token.symbol)
                                .foregroundColor(AppColors.secondaryText)
                            
                            Text("$\(token.price, specifier: "%.2f")")
                                .font(.title3.bold())
                                .foregroundColor(AppColors.accent)
                            
                            Text(token.gainsPercent > 0 ? ("+\(token.gainsPercent, specifier: "%.2f")%") : ("\(token.gainsPercent, specifier: "%.2f")%"))
                                .foregroundColor(token.gainsPercent > 0 ? AppColors.success : AppColors.error)
                        }
                        
                        VStack (spacing: 8) {
                            Text("Your Balance")
                                .foregroundColor(AppColors.secondaryText)
                            
                            Text("\(viewModel.walletToken?.balance ?? 0, specifier: "%.2f") \(token.symbol)")
                                .font(.title.bold())
                                .foregroundColor(AppColors.ink)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.surface)
                        .cornerRadius(20)
                        
                        
                        VStack (alignment: .leading) {
                            Text("Amount")
                                .foregroundColor(AppColors.ink)
                                .font(.headline)
                            
                            HStack {
                                TextField(
                                    "",
                                    text: $amount,
                                    prompt: Text("0.00").foregroundColor(AppColors.secondaryText)
                                )
                                .keyboardType(.decimalPad)
                                .font(.system(size: 30, weight: .semibold))
                                .foregroundColor(AppColors.ink)
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
                                    .foregroundColor(AppColors.secondaryText)
                                    .font(.headline)
                            }
                        }
                        .padding()
                        .background(AppColors.surface)
                        .cornerRadius(SharedLayout.cornerRadius)
                        
                        Button {
                            showingConfirmModal = true
                        } label: {
                            Text("Buy \(token.symbol)")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(amount.isEmpty ? AppColors.surface : AppColors.accent)
                                .foregroundColor(amount.isEmpty ? AppColors.secondaryText : AppColors.ink)
                                .cornerRadius(SharedLayout.cornerRadius)
                        }
                        .disabled(amount.isEmpty)
                    }
                }
                .padding()
            }
        }
        .task {
            await viewModel.loadWalletData(mintAddress: token.mintAddress)
        }
        
        .sheet(isPresented: $showingConfirmModal) {
            VStack(spacing: 24) {
                
                Text("Confirm Purchase")
                    .font(.title2.bold())
                    .foregroundColor(AppColors.ink)
                
                VStack(alignment: .leading, spacing: 16) {
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Token")
                            .foregroundColor(AppColors.ink)
                        
                        Text("\(token.name) (\(token.symbol))")
                            .foregroundColor(AppColors.ink)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Amount")
                            .foregroundColor(AppColors.ink)
                        
                        Text("\(amount) \(token.symbol)")
                            .font(.title3.bold())
                            .foregroundColor(AppColors.ink)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                
                HStack(spacing: 16) {
                    
                    Button {
                        showingConfirmModal = false
                    } label: {
                        Text("Cancel")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.surface)
                            .foregroundColor(AppColors.ink)
                            .cornerRadius(SharedLayout.cornerRadius)
                    }
                    
                    Button {
                        guard let decimalAmount = Decimal(string: amount)
                        else { return }
                        
                        Task {
                            await viewModel.buyToken(mintAddress: token.mintAddress, amount: decimalAmount)
                            
                            if viewModel.errorMessage.isEmpty {
                                amount = ""
                                showingConfirmModal = false
                            }
                            
                            dismiss()
                        }
                        
                    } label: {
                        Text(viewModel.isBuying ? "Purchasing..." : "Purchase")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                viewModel.isBuying
                                ? AppColors.surface
                                : AppColors.accent
                            )
                            .foregroundColor(
                                viewModel.isBuying
                                ? AppColors.secondaryText
                                : AppColors.ink
                            )
                            .cornerRadius(SharedLayout.cornerRadius)
                    }
                    .disabled(viewModel.isBuying)
                }
                
                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(AppColors.error)
                }
            }
            .padding()
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
            .presentationBackground(AppColors.canvas)
        }
    }
    
}



#Preview {
    BuyTokenView(token: TokenListResponse(id: "1", mintAddress: "ahifh1i1fiwq13", name: "Bitcoin", symbol: "BTC", imgUrl: "", price: 121.1, gainsPercent: 2.4))
}
