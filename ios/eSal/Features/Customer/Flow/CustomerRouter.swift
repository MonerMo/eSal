//
//  CustomerRouter.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation
import Observation

// MARK: - Customer Route

enum CustomerRoute: Hashable {
    case receiptDetails(Receipt)
}

// MARK: - Customer Tab

enum CustomerTab: String, CaseIterable, Identifiable {
    case dashboard
    case receipts
    case insights
    case profile

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dashboard: String(localized: "Dashboard")
        case .receipts: String(localized: "Receipts")
        case .insights: String(localized: "Insights")
        case .profile: String(localized: "Profile")
        }
    }

    var icon: String {
        switch self {
        case .dashboard: AppIcons.dashboard
        case .receipts: AppIcons.receipts
        case .insights: AppIcons.analytics
        case .profile: AppIcons.profile
        }
    }
}

// MARK: - Customer Router

@Observable
@MainActor
final class CustomerRouter {

    var selectedTab: CustomerTab = .dashboard
    var dashboardPath: [CustomerRoute] = []
    var receiptsPath: [CustomerRoute] = []
    var insightsPath: [CustomerRoute] = []
    var profilePath: [CustomerRoute] = []

    func select(_ tab: CustomerTab) {
        selectedTab = tab
    }

    func showReceiptDetails(_ receipt: Receipt) {
        receiptsPath.append(.receiptDetails(receipt))
    }

    /// Switches to Receipts and opens details so Back returns to the list.
    func openClaimedReceipt(_ receipt: Receipt) async {
        selectedTab = .receipts
        receiptsPath = []
        await Task.yield()
        try? await Task.sleep(for: .milliseconds(50))
        receiptsPath = [.receiptDetails(receipt)]
    }

    func showReceiptDetailsFromDashboard(_ receipt: Receipt) {
        dashboardPath.append(.receiptDetails(receipt))
    }
}
