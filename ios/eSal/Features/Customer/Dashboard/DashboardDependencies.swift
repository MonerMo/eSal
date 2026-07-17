//
//  DashboardDependencies.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - Dashboard Dependencies

struct DashboardDependencies: Sendable {
    let getDashboard: GetDashboardUseCase

    static func live(client: APIClientProtocol) -> DashboardDependencies {
        let remoteDataSource = DashboardRemoteDataSource(client: client)
        let repository = DashboardRepository(remoteDataSource: remoteDataSource)
        return DashboardDependencies(getDashboard: GetDashboardUseCase(repository: repository))
    }

    @MainActor
    func makeDashboardViewModel(logout: LogoutUseCase) -> DashboardViewModel {
        DashboardViewModel(getDashboard: getDashboard, logout: logout)
    }
}
