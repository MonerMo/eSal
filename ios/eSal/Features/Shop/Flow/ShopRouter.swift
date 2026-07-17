//
//  ShopRouter.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation
import Observation

// MARK: - Shop Route

enum ShopRoute: Hashable {
    case receiptDetails(Receipt)
}

// MARK: - Shop Tab

enum ShopTab: String, CaseIterable, Identifiable {
    case dashboard
    case insights
    case receipts
    case devices
    case profile

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dashboard: String(localized: "Dashboard")
        case .insights: String(localized: "Insights")
        case .receipts: String(localized: "Receipts")
        case .devices: String(localized: "Devices")
        case .profile: String(localized: "Profile")
        }
    }

    var icon: String {
        switch self {
        case .dashboard: AppIcons.dashboard
        case .insights: AppIcons.analytics
        case .receipts: AppIcons.receipts
        case .devices: "qrcode.viewfinder"
        case .profile: AppIcons.profile
        }
    }
}

// MARK: - Shop Router

@Observable
@MainActor
final class ShopRouter {
    var selectedTab: ShopTab = .dashboard
    var dashboardPath: [ShopRoute] = []
    var receiptsPath: [ShopRoute] = []

    func showReceiptDetails(_ receipt: Receipt) {
        receiptsPath.append(.receiptDetails(receipt))
    }

    func showReceiptDetailsFromDashboard(_ receipt: Receipt) {
        dashboardPath.append(.receiptDetails(receipt))
    }
}
