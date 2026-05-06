//
//  Token.swift
//  Assignment3
//
//  Created by Daniel Liu on 5/5/2026.
//

import SwiftUI

struct Token: Identifiable {
    let id = UUID()
    let name: String
    let symbol: String
    let pricePerToken: String
    let balance: String
    let percentChange: String
    let positive: Bool
    let iconUrl: String
    let color: Color
}
