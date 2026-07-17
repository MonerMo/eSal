//
//  ShopDashboardMapper.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

enum ShopDashboardMapper {
    static func map(_ dto: ShopDashboardDTO) -> ShopDashboard {
        ShopDashboard(
            storeName: dto.storeName,
            totalRevenueThisMonth: dto.totalRevenueThisMonth.value,
            receiptCountThisMonth: dto.receiptCountThisMonth,
            recentReceipts: dto.recentReceipts.map(ReceiptMapper.map)
        )
    }
}
