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

    var accessToken: String?

    private let baseURL: URL
    private let session: URLSession
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    private init() {
        baseURL = URL(string: "http://localhost:5000/api")!
        session = .shared
    }

    func get<R: Decodable>(_ path: String) async throws -> R {
        guard let url = URL(string: baseURL.absoluteString + path) else {
            throw APIError.invalidResponse
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        setBearerToken(&request)
        return try await send(request)
    }

    func post<B: Encodable, R: Decodable>(_ path: String, body: B) async throws -> R {
        guard let url = URL(string: baseURL.absoluteString + path) else {
            throw APIError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        setBearerToken(&request)
        request.httpBody = try encoder.encode(body)

        return try await send(request)
    }

    func multipart<R: Decodable>(_ path: String, fields: [String: String], imageData: Data, imageMimeType: String) async throws -> R {
        guard let url = URL(string: baseURL.absoluteString + path) else {
            throw APIError.invalidResponse
        }

        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        setBearerToken(&request)

        var body = Data()
        for (key, value) in fields {
            body += "--\(boundary)\r\nContent-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)\r\n"
        }
        body += "--\(boundary)\r\nContent-Disposition: form-data; name=\"image\"; filename=\"image\"\r\nContent-Type: \(imageMimeType)\r\n\r\n"
        body.append(imageData)
        body += "\r\n--\(boundary)--\r\n"

        request.httpBody = body
        return try await send(request)
    }

    // MARK: - Private

    private func setBearerToken(_ request: inout URLRequest) {
        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
    }

    private func send<R: Decodable>(_ request: URLRequest) async throws -> R {
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

// MARK: - Data Helper

private extension Data {
    static func += (lhs: inout Data, rhs: String) {
        if let data = rhs.data(using: .utf8) { lhs.append(data) }
    }
}
