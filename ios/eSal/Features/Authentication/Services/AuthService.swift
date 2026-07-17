//
//  AuthService.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - Auth Service

/// Live authentication service backed by the REST API.
struct AuthService: AuthServiceProtocol {

    private let baseURL: URL
    private let session: URLSession

    init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    func login(_ request: LoginRequest) async throws -> LoginResponse {
        let data = try await post(path: "auth/login", body: request, endpoint: .login)
        do {
            return try JSONDecoder().decode(LoginResponse.self, from: data)
        } catch {
            throw AuthError.invalidResponse
        }
    }

    func signUp(_ request: SignUpRequest) async throws {
        _ = try await post(path: "auth/signup", body: request, endpoint: .signUp)
    }

    // MARK: - Networking

    private enum AuthEndpoint {
        case login
        case signUp
    }

    private func post<Body: Encodable>(
        path: String,
        body: Body,
        endpoint: AuthEndpoint
    ) async throws -> Data {
        var urlRequest = URLRequest(url: baseURL.appendingPathComponent(path))
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(body)
        urlRequest.timeoutInterval = 60

        NetworkLogger.logRequest(urlRequest)

        let data: Data
        let http: HTTPURLResponse

        do {
            let (responseData, response) = try await session.data(for: urlRequest)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AuthError.invalidResponse
            }
            data = responseData
            http = httpResponse
            NetworkLogger.logResponse(data: data, response: httpResponse)
        } catch let urlError as URLError {
            NetworkLogger.logError(urlError, url: urlRequest.url)
            throw AuthError.network
        } catch let error as AuthError {
            throw error
        } catch {
            NetworkLogger.logError(error, url: urlRequest.url)
            throw AuthError.invalidResponse
        }

        switch http.statusCode {
        case 200..<300:
            return data
        default:
            throw mapAuthError(statusCode: http.statusCode, data: data, endpoint: endpoint)
        }
    }

    private func mapAuthError(
        statusCode: Int,
        data: Data,
        endpoint: AuthEndpoint
    ) -> AuthError {
        switch statusCode {
        case 401 where endpoint == .login:
            return .invalidCredentials
        case 400:
            let messages = APIErrorParser.validationMessages(from: data)
            if messages.isEmpty {
                return .server(APIErrorParser.message(from: data, fallbackStatusCode: statusCode))
            }
            return .validationErrors(messages)
        case 409 where endpoint == .signUp:
            return .emailAlreadyInUse
        default:
            return .server(APIErrorParser.message(from: data, fallbackStatusCode: statusCode))
        }
    }
}
