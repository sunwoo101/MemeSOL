import SwiftUI

struct PrimaryButton: View {
    let label: String
    var disabled: Bool = false
    var destructive: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(disabled ? AppColors.surface : (destructive ? AppColors.error : AppColors.accent))
                .foregroundColor(disabled ? AppColors.secondaryText : AppColors.ink)
                .cornerRadius(SharedLayout.cornerRadius)
        }
        .disabled(disabled)
    }
}

struct SecondaryButton: View {
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(AppColors.surface)
                .foregroundColor(AppColors.ink)
                .cornerRadius(SharedLayout.cornerRadius)
        }
    }
}
