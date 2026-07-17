//
//  ShopDeviceRepositoryProtocol.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

protocol ShopDeviceRepositoryProtocol: Sendable {
    func getDevices() async throws -> [ShopDevice]
}
