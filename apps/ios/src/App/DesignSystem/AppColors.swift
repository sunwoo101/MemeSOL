//
//  AppColors.swift
//  Assignment3
//
//  Created by Daniel Liu  on 5/5/2026.
//

import SwiftUI

enum AppColors {
    static let canvas = Color(red: 0.106, green: 0.094, blue: 0.129)   // #1b1821
    static let ink = Color(red: 0.910, green: 0.914, blue: 0.914)       // #e8e9e9
    static let accent = Color(red: 0.698, green: 0.231, blue: 0.910)    // #b23be8
    static let success = Color(red: 0.286, green: 0.780, blue: 0.369)   // #49c75e
    static let warning = Color(red: 0.925, green: 0.761, blue: 0.298)   // #ecc24c
    static let error = Color(red: 0.890, green: 0.310, blue: 0.306)     // #e34f4e
    static let info = Color(red: 0.365, green: 0.486, blue: 0.859)      // #5d7cdb
    static let surface = ink.opacity(0.08)                               // card surface derived from ink
    static let secondaryText = ink.opacity(0.6)
}
