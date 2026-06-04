//
//  CreateTokenView.swift
//  App
//
//  Created by Gurpreet on 8/5/2026.
//

import SwiftUI
import PhotosUI

struct CreateTokenView: View {
    @State private var step = 0
    @State private var goingForward = true

    // Step 0
    @State private var name = ""
    @State private var symbol = ""
    @State private var supply = ""

    // Step 1
    @State private var imFeelingLucky = false
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: Image?
    @State private var imageData: Data?

    var onDone: () -> Void = {}

    @StateObject private var viewModel = CreateTokenViewModel()

    private var step0Valid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !symbol.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !supply.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var step1Valid: Bool {
        imFeelingLucky || imageData != nil
    }

    private var directionalTransition: AnyTransition {
        .asymmetric(
            insertion: .move(edge: goingForward ? .trailing : .leading),
            removal: .move(edge: goingForward ? .leading : .trailing)
        )
    }

    private func advance() {
        goingForward = true
        withAnimation(.easeInOut(duration: 0.3)) { step += 1 }
    }

    private func back() {
        goingForward = false
        withAnimation(.easeInOut(duration: 0.3)) { step -= 1 }
    }

    private func clearForm() {
        step = 0
        name = ""; symbol = ""; supply = ""
        imFeelingLucky = false
        selectedItem = nil; selectedImage = nil; imageData = nil
    }

    var body: some View {
        ZStack {
            AppColors.canvas.ignoresSafeArea()

            VStack(spacing: 0) {
                // Step dots
                HStack(spacing: 6) {
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .fill(i == step ? AppColors.accent : AppColors.ink.opacity(0.2))
                            .frame(width: i == step ? 8 : 6, height: i == step ? 8 : 6)
                            .animation(.easeInOut(duration: 0.2), value: step)
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 20)

                // Step content with directional slide
                ZStack {
                    if step == 0 {
                        step0View
                            .transition(directionalTransition)
                    } else if step == 1 {
                        step1View
                            .transition(directionalTransition)
                    } else {
                        step2View
                            .transition(directionalTransition)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, SharedLayout.horizontalPadding)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            // Creating / error overlay
            if viewModel.isCreating || !viewModel.errorMessage.isEmpty {
                Color.black.opacity(0.6).ignoresSafeArea()

                if viewModel.isCreating {
                    VStack(spacing: 24) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: AppColors.accent))
                            .scaleEffect(1.6)

                        VStack(spacing: 8) {
                            Text("Creating Your Token")
                                .font(.title3.bold())
                                .foregroundColor(AppColors.ink)
                            Text(imFeelingLucky
                                 ? "Generating your image and minting..."
                                 : "Minting your token on Solana...")
                                .font(.subheadline)
                                .foregroundColor(AppColors.secondaryText)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(36)
                    .background(AppColors.canvas)
                    .cornerRadius(SharedLayout.cornerRadius)
                    .padding(.horizontal, 40)
                } else {
                    VStack(spacing: 24) {
                        ZStack {
                            Circle()
                                .fill(AppColors.error.opacity(0.12))
                                .frame(width: 72, height: 72)
                            Image(systemName: "xmark")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundColor(AppColors.error)
                        }

                        VStack(spacing: 8) {
                            Text("Something went wrong")
                                .font(.title3.bold())
                                .foregroundColor(AppColors.ink)
                            Text(viewModel.errorMessage)
                                .font(.subheadline)
                                .foregroundColor(AppColors.secondaryText)
                                .multilineTextAlignment(.center)
                        }

                        PrimaryButton(label: "Try Again") {
                            viewModel.errorMessage = ""
                        }
                    }
                    .padding(36)
                    .background(AppColors.canvas)
                    .cornerRadius(SharedLayout.cornerRadius)
                    .padding(.horizontal, 40)
                }
            }

            // Success screen
            if viewModel.creationSuccess {
                AppColors.canvas.ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .fill(AppColors.success.opacity(0.12))
                                .frame(width: 88, height: 88)
                            Image(systemName: "checkmark")
                                .font(.system(size: 36, weight: .semibold))
                                .foregroundColor(AppColors.success)
                        }

                        VStack(spacing: 6) {
                            Text("Token Created!")
                                .font(.title2.bold())
                                .foregroundColor(AppColors.ink)
                            Text(name)
                                .font(.subheadline)
                                .foregroundColor(AppColors.secondaryText)
                        }
                    }

                    Spacer()

                    PrimaryButton(label: "Done") {
                        onDone()
                    }
                    .padding(.horizontal)
                    .padding(.bottom, SharedLayout.horizontalPadding)
                }
                .transition(.opacity)
            }
        }
        .navigationBarBackButtonHidden(viewModel.isCreating)
        .background(NavigationLock(isLocked: viewModel.isCreating))
        .task(id: selectedItem) {
            guard let selectedItem else { return }
            if let data = try? await selectedItem.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                imageData = data
                selectedImage = Image(uiImage: uiImage)
            }
        }
    }

    // MARK: - Step 0: Name, Symbol, Supply

    private var step0View: some View {
        VStack(spacing: 0) {
            Text("New Token")
                .font(.subheadline.bold())
                .foregroundColor(AppColors.ink)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 24)

            VStack(spacing: 16) {
                AppTextField(label: "Token Name", placeholder: "e.g. MemeSOL", text: $name)
                AppTextField(label: "Token Symbol", placeholder: "e.g. MSOL", text: $symbol)
                    .onChange(of: symbol) { _, new in symbol = new.uppercased() }
                AppTextField(label: "Total Supply", placeholder: "e.g. 1000000000", text: $supply, keyboardType: .numberPad)
                    .onChange(of: supply) { _, new in supply = new.filter { "0123456789".contains($0) } }
            }

            Spacer()

            PrimaryButton(label: "Next", disabled: !step0Valid) { advance() }
        }
    }

    // MARK: - Step 1: Image

    private var step1View: some View {
        VStack(spacing: 0) {
            Text("Token Image")
                .font(.subheadline.bold())
                .foregroundColor(AppColors.ink)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 24)

            VStack(spacing: 16) {
                // Dashed square upload
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    ZStack {
                        RoundedRectangle(cornerRadius: SharedLayout.cornerRadius)
                            .fill(AppColors.surface)
                        RoundedRectangle(cornerRadius: SharedLayout.cornerRadius)
                            .strokeBorder(
                                style: StrokeStyle(lineWidth: 1.5, dash: [6, 4])
                            )
                            .foregroundColor(AppColors.ink.opacity(imFeelingLucky ? 0.08 : 0.2))

                        if let selectedImage, !imFeelingLucky {
                            GeometryReader { proxy in
                                selectedImage
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: proxy.size.width, height: proxy.size.height)
                                    .clipped()
                            }
                        } else {
                            VStack(spacing: 10) {
                                ZStack {
                                    Circle()
                                        .fill(AppColors.ink.opacity(0.06))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: imFeelingLucky ? "sparkles" : "arrow.up.circle")
                                        .font(.system(size: 22))
                                        .foregroundColor(AppColors.ink.opacity(imFeelingLucky ? 0.15 : 0.4))
                                }
                                Text(imFeelingLucky ? "Image will be generated" : "Tap to upload")
                                    .font(.caption)
                                    .foregroundColor(AppColors.ink.opacity(imFeelingLucky ? 0.2 : 0.4))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: SharedLayout.cornerRadius))
                }
                .disabled(imFeelingLucky)

                // I'm Feeling Lucky toggle
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("I'm Feeling Lucky")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(AppColors.ink.opacity(0.8))
                        Text("AI generate an image")
                            .font(.caption2)
                            .foregroundColor(AppColors.ink.opacity(0.35))
                    }
                    Spacer()
                    Toggle("", isOn: $imFeelingLucky)
                        .labelsHidden()
                        .tint(AppColors.accent)
                        .onChange(of: imFeelingLucky) { _, on in
                            if on {
                                selectedItem = nil
                                selectedImage = nil
                                imageData = nil
                            }
                        }
                }
                .padding()
                .background(AppColors.surface)
                .cornerRadius(SharedLayout.cornerRadius)
            }

            Spacer()

            HStack(spacing: 12) {
                backButton
                PrimaryButton(label: "Next", disabled: !step1Valid) { advance() }
            }
        }
    }

    // MARK: - Step 2: Review

    private var step2View: some View {
        VStack(spacing: 0) {
            Text("Review")
                .font(.subheadline.bold())
                .foregroundColor(AppColors.ink)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 24)

            VStack(spacing: 16) {
                // Token image / lucky placeholder
                Group {
                    if imFeelingLucky {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(
                                    colors: [AppColors.accent, AppColors.info],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                            Image(systemName: "sparkles")
                                .font(.system(size: 28))
                                .foregroundColor(.white.opacity(0.85))
                        }
                    } else if let selectedImage {
                        selectedImage
                            .resizable()
                            .scaledToFill()
                            .clipShape(Circle())
                    } else {
                        Circle().fill(AppColors.surface)
                    }
                }
                .frame(width: 72, height: 72)

                // Name + symbol
                VStack(spacing: 4) {
                    Text(name)
                        .font(.headline.bold())
                        .foregroundColor(AppColors.ink)
                    Text(symbol)
                        .font(.caption)
                        .foregroundColor(AppColors.ink.opacity(0.4))
                }

                // Details card
                VStack(spacing: 0) {
                    HStack {
                        Text("Supply")
                            .font(.caption2)
                            .foregroundColor(AppColors.ink.opacity(0.4))
                        Spacer()
                        Text(supply)
                            .font(.caption2.weight(.medium))
                            .foregroundColor(AppColors.ink)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                }
                .background(AppColors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: SharedLayout.cornerRadius)
                        .strokeBorder(AppColors.ink.opacity(0.08), lineWidth: 1)
                )
                .cornerRadius(SharedLayout.cornerRadius)
            }

            Spacer()

            HStack(spacing: 12) {
                backButton
                PrimaryButton(label: "Launch") {
                    guard let supplyValue = UInt64(supply) else { return }
                    Task {
                        await viewModel.createToken(
                            name: name,
                            symbol: symbol,
                            supply: supplyValue,
                            image: imFeelingLucky ? nil : imageData,
                            imFeelingLucky: imFeelingLucky
                        )
                    }
                }
            }
        }
    }

    private var backButton: some View {
        Button { back() } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 17, weight: .semibold))
                .frame(width: 52)
                .padding(.vertical, 14)
                .background(AppColors.surface)
                .foregroundColor(AppColors.ink)
                .cornerRadius(SharedLayout.cornerRadius)
        }
    }

}

#Preview {
    CreateTokenView()
}
