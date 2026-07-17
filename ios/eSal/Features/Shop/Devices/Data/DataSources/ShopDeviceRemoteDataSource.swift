//
//  ShopDeviceRemoteDataSource.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

struct ShopDeviceRemoteDataSource: Sendable {
    private let client: APIClientProtocol

    init(client: APIClientProtocol) {
        self.client = client
    }

    func fetchDevices() async throws -> [ShopDeviceDTO] {
        try await client.get("shop/devices")
    }
}
