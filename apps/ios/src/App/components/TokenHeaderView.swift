import SwiftUI

struct TokenHeaderView: View {
    let token: TokenListResponse

    var body: some View {
        VStack(spacing: 16) {
            AsyncImage(url: URL(string: token.imgUrl)) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Circle().fill(AppColors.surface)
            }
            .frame(width: 120, height: 120)
            .clipShape(Circle())

            VStack(spacing: 6) {
                Text(token.name)
                    .font(.title.bold())
                    .foregroundColor(AppColors.ink)
                Text(token.symbol)
                    .font(.subheadline)
                    .foregroundColor(AppColors.secondaryText)
                Text("$\(token.price, specifier: "%.2f")")
                    .font(.title3.bold())
                    .foregroundColor(AppColors.accent)
                Text(token.gainsPercent >= 0
                     ? "+\(token.gainsPercent, specifier: "%.2f")%"
                     : "\(token.gainsPercent, specifier: "%.2f")%")
                    .font(.subheadline)
                    .foregroundColor(token.gainsPercent >= 0 ? AppColors.success : AppColors.error)
            }
        }
    }
}
