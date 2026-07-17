//
//  ShopDashboard.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

struct ShopDashboard: Sendable, Equatable {
    let storeName: String
    let totalRevenueThisMonth: Decimal
    let receiptCountThisMonth: Int
    let recentReceipts: [Receipt]
}

extension ShopDashboard {
    static let sample = ShopDashboard(
        storeName: "MonirElectronics",
        totalRevenueThisMonth: 6_321.6,
        receiptCountThisMonth: 14,
        recentReceipts: [.sample]
    )
}
