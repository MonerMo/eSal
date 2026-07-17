//
//  AuthModels.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - Login

struct LoginRequest: Codable, Sendable {
    let email: String
    let password: String
}

struct LoginResponse: Codable, Sendable {
    let accessToken: String
}

// MARK: - Sign Up

/// Registration payload. `storeName` is included only for shop accounts;
/// it is omitted entirely from the JSON for customers (optional + `encodeIfPresent`).
struct SignUpRequest: Codable, Sendable {
    let email: String
    let password: String
    let name: String
    let phone: String
    let accountType: AccountType
    let storeName: String?

    enum CodingKeys: String, CodingKey {
        case email, password, name, phone, accountType, storeName
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(email, forKey: .email)
        try container.encode(password, forKey: .password)
        try container.encode(name, forKey: .name)
        try container.encode(phone, forKey: .phone)
        try container.encode(accountType, forKey: .accountType)
        try container.encodeIfPresent(storeName, forKey: .storeName)
    }
}

// MARK: - User

/// The authenticated user profile as represented by the backend.
struct User: Codable, Sendable, Identifiable {
    let id: String
    let name: String
    let email: String
    let phone: String
    let accountType: AccountType
    let storeName: String?
}
