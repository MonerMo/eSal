//
//  ShopDashboardDependencies.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

struct ShopDashboardDependencies: Sendable {
    let getDashboard: GetShopDashboardUseCase

    static func live(client: APIClientProtocol) -> ShopDashboardDependencies {
        let remoteDataSource = ShopDashboardRemoteDataSource(client: client)
        let repository = ShopDashboardRepository(remoteDataSource: remoteDataSource)
        return ShopDashboardDependencies(getDashboard: GetShopDashboardUseCase(repository: repository))
    }

    @MainActor
    func makeShopDashboardViewModel(logout: LogoutUseCase) -> ShopDashboardViewModel {
        ShopDashboardViewModel(getDashboard: getDashboard, logout: logout)
    }
}
