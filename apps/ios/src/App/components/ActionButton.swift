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
                ZStack {
                    Circle()
                        .fill(AppColors.charcoalColor)
                        .frame(width: ActionButtonLayout.circleSize, height: ActionButtonLayout.circleSize)
                    Image(systemName: icon)
                        .font(.system(size: ActionButtonLayout.iconSize))
                        .foregroundColor(.white)
                }
                Text(label)
                    .font(.caption)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, ActionButtonLayout.verticalPadding)
        }
    }
}
