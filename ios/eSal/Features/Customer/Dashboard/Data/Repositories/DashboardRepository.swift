//
//  DashboardRepository.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - Dashboard Repository

struct DashboardRepository: DashboardRepositoryProtocol {

    private let remoteDataSource: DashboardRemoteDataSource

    init(remoteDataSource: DashboardRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }

    func fetchDashboard() async throws -> Dashboard {
        let dto = try await remoteDataSource.fetchDashboard()
        return DashboardMapper.map(dto)
    }
}
