//
//  CreateTokenView.swift
//  App
//
//  Created by Gurpreet on 8/5/2026.
//

import SwiftUI

struct CreateTokenView: View {
    @State private var name = ""
    @State private var symbol = ""
    @State private var supply = ""
    @State private var image: Data?
    
    @StateObject private var viewModel = CreateTokenViewModel()
    
    //check there are values for name, symbol, image and supply
    //if these conditions are met -> variable equals true
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        !symbol.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        !supply.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        image != nil
    }
    
    
    var body: some View {
        ZStack {
            AppColors.blackColor.ignoresSafeArea()
            
            VStack (spacing: 20) {
                Text("Create Token")
                    .font(.title2.bold())
                    .foregroundColor(AppColors.goldColor)
                    .padding(.top, 10)
                
                //token name
                VStack (alignment: .leading, spacing: 10) {
                    Text("Token Name")
                        .foregroundColor(.white)
                        .font(.headline)
                    HStack {
                        TextField("",
                                  text: $name,
                                  prompt: Text("Enter token name").foregroundColor(AppColors.secondaryTextColor))
                    }
                    .foregroundColor(.white)
                    .background(AppColors.charcoalColor)
                    .cornerRadius(SharedLayout.cornerRadius)
                }
                
                //token symbol
                VStack (alignment: .leading, spacing: 10) {
                    Text("Token Symbol")
                        .foregroundColor(.white)
                        .font(.headline)
                    HStack {
                        TextField("",
                                  text: $symbol,
                                  prompt: Text("Enter token symbol").foregroundColor(AppColors.secondaryTextColor))
                    }
                    .foregroundColor(.white)
                    .background(AppColors.charcoalColor)
                    .cornerRadius(SharedLayout.cornerRadius)
                }
                
                //token supply
                VStack (alignment: .leading, spacing: 10) {
                    Text("Supply")
                        .foregroundColor(.white)
                        .font(.headline)
                    HStack {
                        TextField("",
                                  text: $supply,
                                  prompt: Text("Enter token supply").foregroundColor(AppColors.secondaryTextColor))
                        .keyboardType(.decimalPad)
                        .onChange(of: supply) {
                            let filtered = supply.filter { "0123456789".contains($0)}
                            supply = filtered
                        }
                    }
                    .foregroundColor(.white)
                    .background(AppColors.charcoalColor)
                    .cornerRadius(SharedLayout.cornerRadius)
                }
                
                
                
                
                
                //upload image
                Button() {
                    //upload image
                } label: {
                    Text("Upload Token Image")
                        .foregroundColor(.white)
                }
                
                //create token
                Button() {
                    //api call for create token
                } label: {
                    Text("Create Token")
                        .foregroundColor(.white)
                }
                .disabled(!isFormValid) //if form not valid disable button
            }
            .padding()
        }
    }
}

#Preview {
    CreateTokenView()
}
