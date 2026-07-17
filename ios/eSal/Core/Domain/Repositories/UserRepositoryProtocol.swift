//
//  UserRepositoryProtocol.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - User Repository

protocol UserRepositoryProtocol: Sendable {
    func fetchCurrentUser() async throws -> UserSession
}
