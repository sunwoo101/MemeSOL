//
//  SharedLayout.swift
//  Assignment3
//
//  Created by Daniel Liu on 5/5/2026.
//

import SwiftUI

enum SharedLayout {
    static let cornerRadius: CGFloat = 14
    static let horizontalPadding: CGFloat = 20
    static let sectionSpacing: CGFloat = 20
    static let sectionHeaderSpacing: CGFloat = 6
    static let dividerLeadingPadding: CGFloat = 56
    static let dividerOpacity: Double = 0.2
}

enum AppBehavior {
    // Artificial delay so users can feel the refresh even on fast/cached responses.
    static let artificialRefreshDuration: Duration = .seconds(0.5)
}
