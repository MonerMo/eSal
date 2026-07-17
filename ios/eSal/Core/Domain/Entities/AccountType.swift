//
//  AccountType.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - Account Type

/// The kind of account returned by the backend (`GET /users/me`).
///
/// Raw values match the API contract (`CUSTOMER` / `SHOP`).
enum AccountType: String, Codable, Sendable, Hashable, CaseIterable {
    case customer = "CUSTOMER"
    case shop = "SHOP"

    var title: String {
        switch self {
        case .customer: String(localized: "Customer")
        case .shop: String(localized: "Shop")
        }
    }

    var icon: String {
        switch self {
        case .customer: AppIcons.customer
        case .shop: AppIcons.shop
        }
    }

    /// Account types with a registered application flow in this build.
    var isSupported: Bool {
        switch self {
        case .customer, .shop: true
        }
    }
}
