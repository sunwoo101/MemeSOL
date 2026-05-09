import SwiftUI

struct AllCoinsView: View {
    var body: some View {
        NavigationStack {
            Text("All coins page coming soon.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            .navigationTitle("All Coins")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    AllCoinsView()
}
