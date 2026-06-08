import UIKit

final class ImageCache {
    static let shared = ImageCache()

    private let memory = NSCache<NSString, UIImage>()
    private let diskDirectory: URL = {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let dir = caches.appendingPathComponent("TokenImages")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    private init() {
        memory.countLimit = 100
    }

    func memoryImage(for key: NSString) -> UIImage? {
        memory.object(forKey: key)
    }

    func diskImage(for key: NSString) -> UIImage? {
        let file = diskURL(for: key)
        guard let data = try? Data(contentsOf: file), let image = UIImage(data: data) else {
            return nil
        }
        memory.setObject(image, forKey: key)
        return image
    }

    func store(_ image: UIImage, for key: NSString) {
        memory.setObject(image, forKey: key)
        let file = diskURL(for: key)
        try? image.pngData()?.write(to: file)
    }

    private func diskURL(for key: NSString) -> URL {
        let filename = key.hash.magnitude.description
        return diskDirectory.appendingPathComponent(filename)
    }
}
