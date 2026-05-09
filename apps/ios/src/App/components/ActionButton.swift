//
//  ActionButton.swift
//  Assignment3
//
//  Created by Daniel Liu  on 5/5/2026.
//

import SwiftUI

struct ActionButton: View {
    let icon: String
    let label: String
    
    var body: some View {
        Button {} label: {
            VStack(spacing: ActionButtonLayout.contentSpacing) {
                Image(systemName: icon)
                    .font(.system(size: ActionButtonLayout.iconSize))
                    .foregroundColor(.white)
                    .frame(
                        width: ActionButtonLayout.circleSize,
                        height: ActionButtonLayout.circleSize
                    )
                    .background(AppColors.charcoalColor)
                    .clipShape(Circle())
                Text(label)
                    .font(.caption)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, ActionButtonLayout.verticalPadding)
        }
    }
}
