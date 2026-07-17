//
//  MockInsightsRepository.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - Mock Insights Repository

struct MockInsightsRepository: InsightsRepositoryProtocol {

    private let simulatedDelay: Duration
    private let insightsByRange: [InsightsRange: Insights]

    init(
        insightsByRange: [InsightsRange: Insights] = [.thisMonth: .sample],
        simulatedDelay: Duration = .milliseconds(600)
    ) {
        self.insightsByRange = insightsByRange
        self.simulatedDelay = simulatedDelay
    }

    func fetchInsights(range: InsightsRange) async throws -> Insights {
        try await Task.sleep(for: simulatedDelay)
        return insightsByRange[range] ?? Insights(
            range: range,
            totalSpending: 0,
            categories: []
        )
    }
}
