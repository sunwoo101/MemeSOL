import Foundation

// MARK: - Error

enum APIError: LocalizedError {
    case serverError(String)
    case invalidResponse
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .serverError(let message): message
        case .invalidResponse: "Invalid server response."
        case .decodingFailed: "Failed to decode server response."
        }
    }
}

private struct APIErrorBody: Decodable {
    let message: String
}

// MARK: - Client

final class APIClient {
    static let shared = APIClient()

    private let baseURL: URL
    private let session: URLSession
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    private init() {
        baseURL = URL(string: "http://localhost:5000/api")!
        session = .shared
    }

    func post<B: Encodable, R: Decodable>(_ path: String, body: B) async throws -> R {
        guard let url = URL(string: baseURL.absoluteString + path) else {
            throw APIError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(body)

        let (data, response) = try await session.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(http.statusCode) else {
            let msg = (try? decoder.decode(APIErrorBody.self, from: data))?.message ?? "Unknown error."
            throw APIError.serverError(msg)
        }

        do {
            return try decoder.decode(R.self, from: data)
        } catch {
            throw APIError.decodingFailed
        }
    }
}
