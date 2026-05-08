//
//  CreateTokenView.swift
//  App
//
//  Created by Gurpreet on 8/5/2026.
//

import SwiftUI
import PhotosUI

struct CreateTokenView: View {
    @State private var name = ""
    @State private var symbol = ""
    @State private var supply = ""
    
    @State private var selectedItem: PhotosPickerItem? //image user selected from photo library
    @State private var selectedImage: Image? //to display image
    @State private var imageData: Data? //image data for api
    
    @StateObject private var viewModel = CreateTokenViewModel()
    
    private var isCreateDisabled: Bool {
        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        symbol.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        supply.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        imageData == nil
    }
    
    var body: some View {
        ZStack {
            AppColors.blackColor.ignoresSafeArea()
            
            VStack (spacing: 20) {
                Text("Create Token")
                    .font(.title2.bold())
                    .foregroundColor(AppColors.goldColor)
                    .padding(.top, 10)
                
                //upload image
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    VStack(spacing: 10) {
                        if let selectedImage {
                            selectedImage
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                        } else {
                            ZStack {
                                Circle()
                                    .fill(AppColors.charcoalColor)
                                    .frame(width: 120, height: 120)
                                Image(systemName: "photo")
                                    .font(.system(size: 35))
                                    .foregroundColor(.white.opacity(0.75))
                            }
                        }
                        Text("Upload Token Image")
                            .foregroundColor(.white)
                    }
                }
                
                //token name
                VStack (alignment: .leading, spacing: 10) {
                    Text("Token Name")
                        .foregroundColor(.white)
                        .font(.headline)
                    HStack {
                        TextField("",
                                  text: $name,
                                  prompt: Text("Enter token name").foregroundColor(AppColors.secondaryTextColor))
                        .padding()
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
                        .padding()
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
                        .padding()
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
                .padding(.bottom, 15)
                
                //create token
                Button {
                    guard let imageData, let supplyValue = UInt64(supply)
                    else { return }
                    Task {
                        await viewModel.createToken(name: name, symbol: symbol, supply: supplyValue, image: imageData)
                    }
                } label: {
                    Text(viewModel.isCreating ? "Creating..." : "Create Token")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isCreateDisabled || viewModel.isCreating ? AppColors.charcoalColor : AppColors.goldColor)
                        .foregroundColor(isCreateDisabled || viewModel.isCreating ? AppColors.secondaryTextColor : .black)
                        .cornerRadius(SharedLayout.cornerRadius)
                }
                .disabled(isCreateDisabled || viewModel.isCreating)
                
                Spacer()
            }
            .padding()
        }
        .task(id: selectedItem) {
            guard let selectedItem else { return }
            
            if let data = try? await selectedItem.loadTransferable(type: Data.self) {
                imageData = data
                if let uiImage = UIImage(data: data) {
                    selectedImage = Image(uiImage: uiImage)
                }
            }
        }
    }
}

#Preview {
    CreateTokenView()
}

//things to do:
//make symbol input uppercase
//symbol has to be between 3 and 6 characters
//token name cannot be longer than 20 characters
