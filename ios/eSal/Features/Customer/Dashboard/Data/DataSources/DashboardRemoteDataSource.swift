//
//  DashboardRemoteDataSource.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - Dashboard Remote Data Source

struct DashboardRemoteDataSource: Sendable {

    private let client: APIClientProtocol

    init(client: APIClientProtocol) {
        self.client = client
    }

    func fetchDashboard() async throws -> DashboardDTO {
        try await client.get("dashboard")
    }
}
