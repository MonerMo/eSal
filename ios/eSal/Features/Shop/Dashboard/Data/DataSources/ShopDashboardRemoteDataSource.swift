//
//  ShopDashboardRemoteDataSource.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

struct ShopDashboardRemoteDataSource: Sendable {
    private let client: APIClientProtocol

    init(client: APIClientProtocol) {
        self.client = client
    }

    func fetchDashboard() async throws -> ShopDashboardDTO {
        try await client.get("shop/dashboard")
    }
}
