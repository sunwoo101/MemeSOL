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
                .padding()
                .foregroundColor(AppColors.ink)
                .keyboardType(keyboardType)
                .background(AppColors.surface)
                .cornerRadius(SharedLayout.cornerRadius)
        }
    }
}
