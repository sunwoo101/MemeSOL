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
    let message: String?
    let error: String?
    let details: [String]?
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
            if let decoded = try? decoder.decode(APIErrorBody.self, from: data) {
                if let message = decoded.message, !message.isEmpty {
                    throw APIError.serverError(message)
                }
                if let error = decoded.error, !error.isEmpty {
                    throw APIError.serverError(error)
                }
                if let details = decoded.details, !details.isEmpty {
                    throw APIError.serverError(details.joined(separator: "\n"))
                }
            }

            let rawBody = String(data: data, encoding: .utf8)?
                .trimmingCharacters(in: .whitespacesAndNewlines)
            let fallback = rawBody?.isEmpty == false ? rawBody! : "Unknown error."
            throw APIError.serverError("Request failed (\(http.statusCode)): \(fallback)")
        }

        do {
            return try decoder.decode(R.self, from: data)
        } catch {
            throw APIError.decodingFailed
        }
    }
}
