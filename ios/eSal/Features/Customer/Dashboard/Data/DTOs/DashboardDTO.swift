//
//  DashboardDTO.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - Dashboard DTO

struct DashboardDTO: Decodable, Sendable {
    let firstName: String
    let totalSpendingThisMonth: DecimalString
    let nearestWarranty: DashboardNearestWarrantyDTO?
    let recentReceipts: [ReceiptDTO]
    let smartOffers: [SmartOfferDTO]
}

struct DashboardNearestWarrantyDTO: Decodable, Sendable {
    let itemName: String
    let storeName: String
    let warrantyEndDate: Date
    let receiptId: String
    let receipt: ReceiptDTO?
}

struct SmartOfferDTO: Decodable, Sendable {
    let id: String?
    let title: String
    let description: String
    let imageUrl: String?
}
