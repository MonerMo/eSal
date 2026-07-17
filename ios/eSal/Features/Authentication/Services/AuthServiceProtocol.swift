//
//  AuthServiceProtocol.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - Auth Service Protocol

/// Abstraction over authentication networking.
///
/// View models depend only on this protocol, so the concrete implementation
/// (`AuthService`) can be swapped via dependency injection.
protocol AuthServiceProtocol: Sendable {
    func login(_ request: LoginRequest) async throws -> LoginResponse
    func signUp(_ request: SignUpRequest) async throws
}

// MARK: - Auth Error

enum AuthError: LocalizedError {
    case invalidCredentials
    case validationErrors([String])
    case emailAlreadyInUse
    case invalidResponse
    case server(String)
    case network

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            String(localized: "Invalid Credentials")
        case .validationErrors(let messages):
            messages.joined(separator: "\n")
        case .emailAlreadyInUse:
            String(localized: "An account with this email already exists.")
        case .invalidResponse:
            String(localized: "Unexpected server response. Please try again.")
        case .server(let message):
            message
        case .network:
            String(localized: "No internet connection. Please try again.")
        }
    }
}
