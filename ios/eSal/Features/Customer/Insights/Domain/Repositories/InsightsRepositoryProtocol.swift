//
//  InsightsRepositoryProtocol.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - Insights Repository Protocol

protocol InsightsRepositoryProtocol: Sendable {
    func fetchInsights(range: InsightsRange) async throws -> Insights
}
