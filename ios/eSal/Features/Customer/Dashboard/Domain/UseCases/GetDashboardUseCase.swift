//
//  GetDashboardUseCase.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - Get Dashboard Use Case

struct GetDashboardUseCase: Sendable {

    private let repository: DashboardRepositoryProtocol

    init(repository: DashboardRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> Dashboard {
        try await repository.fetchDashboard()
    }
}
