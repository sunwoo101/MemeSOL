import SwiftUI
import UIKit

struct CachedAsyncImage<Content: View>: View {
    private let url: URL?
    private let content: (AsyncImagePhase) -> Content

    @State private var phase: AsyncImagePhase = .empty

    init(url: URL?, @ViewBuilder content: @escaping (AsyncImagePhase) -> Content) {
        self.url = url
        self.content = content
    }

    var body: some View {
        content(phase)
            .task(id: url) { await load() }
    }

    private func load() async {
        guard let url else { phase = .empty; return }

        let key = url.absoluteString as NSString

        if let cached = ImageCache.shared.memoryImage(for: key) {
            phase = .success(Image(uiImage: cached))
            return
        }

        let fromDisk = await Task.detached(priority: .userInitiated) {
            ImageCache.shared.diskImage(for: key)
        }.value
        if let fromDisk {
            phase = .success(Image(uiImage: fromDisk))
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let uiImage = await Task.detached(priority: .userInitiated) { () -> UIImage? in
                guard let image = UIImage(data: data) else { return nil }
                ImageCache.shared.store(image, for: key)
                return image
            }.value
            if let uiImage {
                phase = .success(Image(uiImage: uiImage))
            } else {
                phase = .failure(URLError(.cannotDecodeContentData))
            }
        } catch {
            phase = .failure(error)
        }
    }
}
