//
//  APIClient.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - API Client Protocol

protocol APIClientProtocol: Sendable {
    func get<T: Decodable>(_ path: String, queryItems: [URLQueryItem]) async throws -> T
    func getData(_ path: String, queryItems: [URLQueryItem]) async throws -> Data
    func post<Body: Encodable>(_ path: String, body: Body) async throws -> Data
    func postDecoded<Response: Decodable, Body: Encodable>(_ path: String, body: Body) async throws -> Response
}

extension APIClientProtocol {
    func get<T: Decodable>(_ path: String) async throws -> T {
        try await get(path, queryItems: [])
    }

    func getData(_ path: String) async throws -> Data {
        try await getData(path, queryItems: [])
    }
}

// MARK: - API Client Error

enum APIClientError: LocalizedError {
    case invalidResponse
    case unauthorized
    case notFound(String = "")
    case forbidden(String)
    case conflict(String)
    case server(String)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            String(localized: "Unexpected server response. Please try again.")
        case .unauthorized:
            String(localized: "Your session has expired. Please sign in again.")
        case .notFound(let message):
            message.isEmpty
                ? String(localized: "We couldn't find what you're looking for.")
                : message
        case .forbidden(let message):
            message.isEmpty
                ? String(localized: "You don't have permission to perform this action.")
                : message
        case .conflict(let message):
            message.isEmpty
                ? String(localized: "This device has already been paired.")
                : message
        case .server(let message):
            message
        }
    }
}

// MARK: - API Client

/// Shared HTTP client. Attaches the JWT when a token provider returns a value.
struct APIClient: APIClientProtocol {

    private let baseURL: URL
    private let session: URLSession
    private let tokenProvider: @Sendable () -> String?
    private let decoder: JSONDecoder

    init(
        baseURL: URL,
        tokenProvider: @escaping @Sendable () -> String?,
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.tokenProvider = tokenProvider
        self.session = session
        self.decoder = JSONDecoder.api()
    }

    func get<T: Decodable>(_ path: String, queryItems: [URLQueryItem] = []) async throws -> T {
        let data = try await request(path: path, method: "GET", queryItems: queryItems, body: nil as Data?)
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            #if DEBUG
            print("❌ [DECODE ERROR] \(T.self) — \(error)")
            if let json = String(data: data, encoding: .utf8) {
                print("   Raw JSON: \(json)")
            }
            #endif
            throw APIClientError.invalidResponse
        }
    }

    func getData(_ path: String, queryItems: [URLQueryItem] = []) async throws -> Data {
        try await request(path: path, method: "GET", queryItems: queryItems, body: nil as Data?)
    }

    func post<Body: Encodable>(_ path: String, body: Body) async throws -> Data {
        let bodyData = try JSONEncoder().encode(body)
        return try await request(path: path, method: "POST", queryItems: [], body: bodyData)
    }

    func postDecoded<Response: Decodable, Body: Encodable>(_ path: String, body: Body) async throws -> Response {
        let bodyData = try JSONEncoder().encode(body)
        let data = try await request(path: path, method: "POST", queryItems: [], body: bodyData)
        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            #if DEBUG
            print("❌ [DECODE ERROR] \(Response.self) — \(error)")
            if let json = String(data: data, encoding: .utf8) {
                print("   Raw JSON: \(json)")
            }
            #endif
            throw APIClientError.invalidResponse
        }
    }

    // MARK: - Private

    private func request(
        path: String,
        method: String,
        queryItems: [URLQueryItem],
        body: Data?
    ) async throws -> Data {
        var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)
        if !queryItems.isEmpty {
            components?.queryItems = queryItems
        }
        guard let url = components?.url else {
            throw APIClientError.invalidResponse
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = body
        urlRequest.timeoutInterval = 60

        if let token = tokenProvider() {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        NetworkLogger.logRequest(urlRequest)

        let data: Data
        let http: HTTPURLResponse

        do {
            let (responseData, response) = try await session.data(for: urlRequest)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIClientError.invalidResponse
            }
            data = responseData
            http = httpResponse
            NetworkLogger.logResponse(data: data, response: httpResponse)
        } catch let urlError as URLError where urlError.code == .cancelled {
            throw CancellationError()
        } catch let urlError as URLError {
            NetworkLogger.logError(urlError, url: urlRequest.url)
            throw AuthError.network
        } catch let error as APIClientError {
            throw error
        } catch let error as AuthError {
            throw error
        } catch {
            NetworkLogger.logError(error, url: urlRequest.url)
            throw APIClientError.invalidResponse
        }

        switch http.statusCode {
        case 200..<300:
            return data
        case 401:
            throw APIClientError.unauthorized
        case 403:
            throw APIClientError.forbidden(
                APIErrorParser.message(from: data, fallbackStatusCode: http.statusCode)
            )
        case 404:
            throw APIClientError.notFound(
                APIErrorParser.message(from: data, fallbackStatusCode: http.statusCode)
            )
        case 409:
            throw APIClientError.conflict(
                APIErrorParser.message(from: data, fallbackStatusCode: http.statusCode)
            )
        default:
            let message = APIErrorParser.message(from: data, fallbackStatusCode: http.statusCode)
            throw APIClientError.server(message)
        }
    }
}
