//
//  GetInsightsUseCase.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - Get Insights Use Case

struct GetInsightsUseCase: Sendable {

    private let repository: InsightsRepositoryProtocol

    init(repository: InsightsRepositoryProtocol) {
        self.repository = repository
    }

    func execute(range: InsightsRange) async throws -> Insights {
        try await repository.fetchInsights(range: range)
    }
}
