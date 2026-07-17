//
//  GetShopDevicesUseCase.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

struct GetShopDevicesUseCase: Sendable {
    private let repository: ShopDeviceRepositoryProtocol

    init(repository: ShopDeviceRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [ShopDevice] {
        try await repository.getDevices()
    }
}
