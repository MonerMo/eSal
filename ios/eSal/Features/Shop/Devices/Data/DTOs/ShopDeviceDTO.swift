//
//  ShopDeviceDTO.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

struct ShopDeviceDTO: Decodable, Sendable {
    let id: String
    let name: String
    let createdAt: Date
}
