//
//  ShopDashboardDTO.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

struct ShopDashboardDTO: Decodable, Sendable {
    let storeName: String
    let totalRevenueThisMonth: DecimalString
    let receiptCountThisMonth: Int
    let recentReceipts: [ReceiptDTO]
}
