//
//  SendView.swift
//  App
//
//  Created by Gurpreet on 6/5/2026.
//

import SwiftUI

struct SendView: View {
    @State var text = ""
    
    
    var body: some View {
        VStack {
            TextField("Enter Recepient Address...", text: $text)
                .padding()
                .background(AppColors.charcoalColor)
                .foregroundColor(.white)
            
            Text("Hello world!")

        }
    }
}

#Preview {
    SendView()
}
