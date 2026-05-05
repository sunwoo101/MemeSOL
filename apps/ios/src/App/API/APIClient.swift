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

// MARK: - RefreshCoordinator

private actor RefreshCoordinator {
    private var task: Task<AuthResponse, Error>?

    func refresh(using perform: @escaping () async throws -> AuthResponse) async throws -> AuthResponse {
        if let existing = task {
            return try await existing.value
        }
        let t = Task { try await perform() }
        task = t
        do {
            let result = try await t.value
            task = nil
            return result
        } catch {
            task = nil
            throw error
        }
    }
}

// MARK: - Client

final class APIClient {
    static let shared = APIClient()

    var accessToken: String?
    var refreshToken: String?

    private let baseURL: URL
    private let session: URLSession
    private let refreshCoordinator = RefreshCoordinator()
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    private init() {
        baseURL = URL(string: "http://localhost:5000/api")!
        session = .shared
        accessToken = KeychainHelper.load(forKey: "accessToken")
        refreshToken = KeychainHelper.load(forKey: "refreshToken")
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

    func post(_ path: String) async throws {
        guard let url = URL(string: baseURL.absoluteString + path) else {
            throw APIError.invalidResponse
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        setBearerToken(&request)
        try await sendVoid(request)
    }

    func delete(_ path: String) async throws {
        guard let url = URL(string: baseURL.absoluteString + path) else {
            throw APIError.invalidResponse
        }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        setBearerToken(&request)
        try await sendVoid(request)
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

    func persistTokens(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        KeychainHelper.save(accessToken, forKey: "accessToken")
        KeychainHelper.save(refreshToken, forKey: "refreshToken")
    }

    func clearTokens() {
        accessToken = nil
        refreshToken = nil
        KeychainHelper.delete(forKey: "accessToken")
        KeychainHelper.delete(forKey: "refreshToken")
    }

    func send<R: Decodable>(_ request: URLRequest, retryOnUnauthorized: Bool = true) async throws -> R {
        let (data, statusCode) = try await execute(request, retryOnUnauthorized: retryOnUnauthorized)
        guard (200...299).contains(statusCode) else {
            let msg = (try? decoder.decode(APIErrorBody.self, from: data))?.message ?? "Unknown error."
            throw APIError.serverError(msg)
        }
        do {
            return try decoder.decode(R.self, from: data)
        } catch {
            throw APIError.decodingFailed
        }
    }

    func sendVoid(_ request: URLRequest, retryOnUnauthorized: Bool = true) async throws {
        let (data, statusCode) = try await execute(request, retryOnUnauthorized: retryOnUnauthorized)
        guard (200...299).contains(statusCode) else {
            let msg = (try? decoder.decode(APIErrorBody.self, from: data))?.message ?? "Unknown error."
            throw APIError.serverError(msg)
        }
    }

    private func execute(_ request: URLRequest, retryOnUnauthorized: Bool) async throws -> (Data, Int) {
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        if http.statusCode == 401, retryOnUnauthorized, let rt = refreshToken {
            let refreshed: AuthResponse
            do {
                refreshed = try await refreshCoordinator.refresh { [weak self] in
                    guard let self else { throw APIError.invalidResponse }
                    return try await self.performRefresh(rt)
                }
                persistTokens(accessToken: refreshed.accessToken, refreshToken: refreshed.refreshToken)
            } catch {
                clearTokens()
                throw APIError.serverError("Session expired. Please log in again.")
            }
            var retried = request
            retried.setValue("Bearer \(refreshed.accessToken)", forHTTPHeaderField: "Authorization")
            return try await execute(retried, retryOnUnauthorized: false)
        }

        return (data, http.statusCode)
    }

    private func performRefresh(_ refreshToken: String) async throws -> AuthResponse {
        struct Body: Encodable { let refreshToken: String }
        guard let url = URL(string: baseURL.absoluteString + "/auth/refresh") else {
            throw APIError.invalidResponse
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(Body(refreshToken: refreshToken))
        return try await send(request, retryOnUnauthorized: false)
    }
}

// MARK: - Data Helper

private extension Data {
    static func += (lhs: inout Data, rhs: String) {
        if let data = rhs.data(using: .utf8) { lhs.append(data) }
    }
}
