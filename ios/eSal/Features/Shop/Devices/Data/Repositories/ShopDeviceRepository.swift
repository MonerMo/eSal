//
//  ShopDeviceRepository.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

struct ShopDeviceRepository: ShopDeviceRepositoryProtocol {
    private let remoteDataSource: ShopDeviceRemoteDataSource

    init(remoteDataSource: ShopDeviceRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }

    func getDevices() async throws -> [ShopDevice] {
        let dtos = try await remoteDataSource.fetchDevices()
        return ShopDeviceMapper.map(dtos)
    }
}
