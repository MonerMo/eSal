//
//  InsightsRepository.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - Insights Repository

struct InsightsRepository: InsightsRepositoryProtocol {

    private let remoteDataSource: InsightsRemoteDataSource

    init(remoteDataSource: InsightsRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }

    func fetchInsights(range: InsightsRange) async throws -> Insights {
        let dto = try await remoteDataSource.fetchInsights(range: range)
        return InsightsMapper.map(dto, requestedRange: range)
    }
}
