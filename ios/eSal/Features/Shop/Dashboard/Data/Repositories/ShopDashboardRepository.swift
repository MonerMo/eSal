//
//  ShopDashboardRepository.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

struct ShopDashboardRepository: ShopDashboardRepositoryProtocol {
    private let remoteDataSource: ShopDashboardRemoteDataSource

    init(remoteDataSource: ShopDashboardRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }

    func getDashboard() async throws -> ShopDashboard {
        let dto = try await remoteDataSource.fetchDashboard()
        return ShopDashboardMapper.map(dto)
    }
}
