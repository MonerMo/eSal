//
//  InsightsDependencies.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - Insights Dependencies

struct InsightsDependencies: Sendable {
    let getInsights: GetInsightsUseCase

    static func live(client: APIClientProtocol) -> InsightsDependencies {
        makeDependencies(client: client, scope: .customer)
    }

    static func liveShop(client: APIClientProtocol) -> InsightsDependencies {
        makeDependencies(client: client, scope: .shop)
    }

    @MainActor
    func makeInsightsViewModel(logout: LogoutUseCase) -> InsightsViewModel {
        InsightsViewModel(getInsights: getInsights, logout: logout)
    }

    private static func makeDependencies(
        client: APIClientProtocol,
        scope: InsightsListScope
    ) -> InsightsDependencies {
        let remoteDataSource = InsightsRemoteDataSource(client: client, scope: scope)
        let repository = InsightsRepository(remoteDataSource: remoteDataSource)
        return InsightsDependencies(getInsights: GetInsightsUseCase(repository: repository))
    }
}
