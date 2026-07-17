//
//  Dashboard.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - Dashboard

/// Customer dashboard aggregate from `GET /dashboard`.
struct Dashboard: Sendable, Equatable {
    let firstName: String
    let totalSpendingThisMonth: Decimal
    let nearestWarranty: DashboardWarranty?
    let recentReceipts: [Receipt]
    let smartOffers: [SmartOffer]
}

// MARK: - Dashboard Warranty

struct DashboardWarranty: Hashable, Sendable {
    let itemName: String
    let storeName: String
    let warrantyEndDate: Date
    let receipt: Receipt

    var formattedWarrantyEndDate: String {
        warrantyEndDate.formatted(date: .abbreviated, time: .omitted)
    }

    var daysUntilExpiry: Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: .now)
        let end = calendar.startOfDay(for: warrantyEndDate)
        return calendar.dateComponents([.day], from: start, to: end).day ?? 0
    }

    var alertMessage: String {
        if daysUntilExpiry <= 0 {
            String(localized: "\(itemName) warranty has expired!")
        } else if daysUntilExpiry == 1 {
            String(localized: "\(itemName) warranty expires tomorrow!")
        } else {
            String(localized: "\(itemName) warranty expires in \(daysUntilExpiry) days!")
        }
    }
}

// MARK: - Smart Offer

struct SmartOffer: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let description: String
    let imageURL: String?
}

// MARK: - Preview Sample

extension Dashboard {
    static let sample = Dashboard(
        firstName: "Monir",
        totalSpendingThisMonth: 980,
        nearestWarranty: DashboardWarranty(
            itemName: "Apple Pencil 2nd Gen",
            storeName: "MonirElectronics",
            warrantyEndDate: .now.addingTimeInterval(60 * 60 * 24 * 90),
            receipt: .sample
        ),
        recentReceipts: [.sample],
        smartOffers: [
            SmartOffer(
                id: "1",
                title: String(localized: "10% Off Electronics"),
                description: String(localized: "Save on your next purchase at partner stores."),
                imageURL: nil
            )
        ]
    )
}
