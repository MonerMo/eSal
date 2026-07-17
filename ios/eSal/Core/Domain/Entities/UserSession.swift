//
//  UserSession.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - User Session

/// Authenticated user profile from `GET /users/me`.
///
/// This is the single source of truth for post-login routing (`accountType`).
struct UserSession: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let name: String
    let email: String
    let phone: String
    let accountType: AccountType
    let createdAt: Date

    var firstName: String {
        name.split(separator: " ").first.map(String.init) ?? name
    }
}
