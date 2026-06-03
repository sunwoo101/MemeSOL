//
//  AppTextField.swift
//  App
//

import SwiftUI

struct AppTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption2.weight(.semibold))
                .foregroundColor(AppColors.ink.opacity(0.4))
                .textCase(.uppercase)
                .tracking(1.0)

            TextField("", text: $text,
                      prompt: Text(placeholder).foregroundColor(AppColors.secondaryText))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .foregroundColor(AppColors.ink)
                .keyboardType(keyboardType)
                .background(AppColors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: SharedLayout.cornerRadius)
                        .strokeBorder(AppColors.ink.opacity(0.08), lineWidth: 1)
                )
                .cornerRadius(SharedLayout.cornerRadius)
        }
    }
}
