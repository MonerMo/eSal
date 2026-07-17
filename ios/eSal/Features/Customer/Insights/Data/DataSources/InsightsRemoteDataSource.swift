//
//  InsightsRemoteDataSource.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - Insights Remote Data Source

struct InsightsRemoteDataSource: Sendable {

    private let client: APIClientProtocol
    private let scope: InsightsListScope

    init(client: APIClientProtocol, scope: InsightsListScope = .customer) {
        self.client = client
        self.scope = scope
    }

    func fetchInsights(range: InsightsRange) async throws -> InsightsDTO {
        try await client.get(
            scope.path,
            queryItems: Self.queryItems(for: range)
        )
    }

    private static func queryItems(for range: InsightsRange) -> [URLQueryItem] {
        guard range != .thisMonth else { return [] }

        return [URLQueryItem(name: "range", value: range.rawValue)]
    }
}
