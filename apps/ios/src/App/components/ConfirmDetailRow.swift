import SwiftUI

struct ConfirmDetailRow: View {
    let label: String
    let value: String
    var prominent: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(AppColors.secondaryText)
            Text(value)
                .font(prominent ? .title3.weight(.bold) : .body)
                .foregroundColor(AppColors.ink)
        }
    }
}
