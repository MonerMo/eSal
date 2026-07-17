//
//  APIUserRepository.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - API User Repository

struct APIUserRepository: UserRepositoryProtocol {

    private let client: APIClientProtocol

    init(client: APIClientProtocol) {
        self.client = client
    }

    func fetchCurrentUser() async throws -> UserSession {
        try await client.get("users/me")
    }
}
