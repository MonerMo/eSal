//
//  ShopDevice.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

struct ShopDevice: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let createdAt: Date
}

extension ShopDevice {
    var formattedCreatedAt: String {
        createdAt.formatted(date: .abbreviated, time: .shortened)
    }

    static let sample = ShopDevice(
        id: "preview",
        name: "New Device",
        createdAt: .now
    )
}
