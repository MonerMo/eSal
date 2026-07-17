//
//  ShopDeviceDependencies.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

struct ShopDeviceDependencies: Sendable {
    let getDevices: GetShopDevicesUseCase

    static func live(client: APIClientProtocol) -> ShopDeviceDependencies {
        let remoteDataSource = ShopDeviceRemoteDataSource(client: client)
        let repository = ShopDeviceRepository(remoteDataSource: remoteDataSource)
        return ShopDeviceDependencies(getDevices: GetShopDevicesUseCase(repository: repository))
    }

    func makeShopDevicesViewModel() -> ShopDevicesViewModel {
        ShopDevicesViewModel(getDevices: getDevices)
    }
}
