//
//  BuyView.swift
//  Assignment3
//

import SwiftUI

struct BuyView: View {
    var body: some View {
        ZStack {
            AppColors.blackColor.ignoresSafeArea()

            VStack(spacing: 12) {
                Text("Buy")
                    .font(.title2.bold())
                    .foregroundColor(AppColors.goldColor)

                Text("Buy flow coming soon.")
                    .foregroundColor(AppColors.secondaryTextColor)
            }
        }
    }
}

#Preview {
    BuyView()
}
