//
//  ActionButton.swift
//  App
//
//  Created by Daniel Liu  on 5/5/2026.
//

import SwiftUI

struct ActionButton: View {
    let icon: String
    let label: String
    
    var body: some View {
        Button {} label: {
            VStack(spacing: AppLayout.actionButtonContentSpacing) {
                Image(systemName: icon)
                    .font(.system(size: AppLayout.actionButtonIconSize))
                    .foregroundColor(.white)
                Text(label)
                    .font(.caption)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppLayout.actionButtonVerticalPadding)
            .background(AppColors.charcoalColor)
            .cornerRadius(AppLayout.cornerRadius)
        }
    }
}
