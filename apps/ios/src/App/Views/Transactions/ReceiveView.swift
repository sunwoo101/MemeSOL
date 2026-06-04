//
//  ReceiveView.swift
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

            VStack(spacing: SharedLayout.sectionSpacing) {
                GeometryReader { geometry in
                    VStack {
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
                        .font(.headline)
                        .foregroundColor(AppColors.ink)
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

                        Button {
                            viewModel.copyAddress(authSession.walletPublicKey)
                        } label: {
                            VStack(spacing: 5) {
                                Image(systemName: "doc.on.doc")
                                Text(viewModel.copyButtonText)
                                    .font(.system(size: 12))
                            }
                            .foregroundColor(AppColors.ink)
                            .padding(.horizontal, 5)
                        }
                    }
                    .padding()
                    .background(AppColors.surface)
                    .cornerRadius(SharedLayout.cornerRadius)
                }
            }
            .padding(.horizontal, SharedLayout.horizontalPadding)
            .padding(.top, SharedLayout.sectionSpacing)
            .padding(.bottom, SharedLayout.horizontalPadding)
        }
        .navigationTitle("Receive")
        .onAppear {
            viewModel.updateQRCode(from: authSession.walletPublicKey)
        }
        .onChange(of: authSession.walletPublicKey) { _, newAddress in
            viewModel.updateQRCode(from: newAddress)
        }
    }
}

#Preview {
    ReceiveView().environment(AuthSession())
}
