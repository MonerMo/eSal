//
//  ShopDeviceMapper.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

enum ShopDeviceMapper {
    static func map(_ dtos: [ShopDeviceDTO]) -> [ShopDevice] {
        dtos.map(map)
    }

    static func map(_ dto: ShopDeviceDTO) -> ShopDevice {
        ShopDevice(
            id: dto.id,
            name: dto.name,
            createdAt: dto.createdAt
        )
    }
}
