//
//  BuyTokenView.swift
//  App
//
//  Created by Gurpreet on 9/5/2026.
//

import SwiftUI

struct BuyTokenView: View {
    let token: TokenListResponse
    
    var body: some View {
        ZStack {
            AppColors.blackColor.ignoresSafeArea()
        }
    }
}

#Preview {
    BuyTokenView(token: TokenListResponse(id: "1", mintAddress: "ahifh1i1fiwq13", name: "Bitcoin", symbol: "BTC", imgUrl: "", price: 121.1, gainsPercent: 2.4))
}
