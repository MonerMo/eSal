//
//  ReceiptFilter.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - Receipt List Scope

enum ReceiptListScope: Sendable {
    case customer
    case shop

    var path: String {
        switch self {
        case .customer: "receipts"
        case .shop: "shop/receipts"
        }
    }
}

// MARK: - Receipt Time Filter

enum ReceiptTimeFilter: String, CaseIterable, Identifiable, Sendable {
    case all
    case thisWeek = "thisWeek"
    case lastMonth = "lastMonth"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .all:
            String(localized: "All")
        case .thisWeek:
            String(localized: "This Week")
        case .lastMonth:
            String(localized: "Last Month")
        }
    }
}

// MARK: - Receipt Category Filter

enum ReceiptCategoryFilter: String, CaseIterable, Identifiable, Sendable {
    case foodAndDining = "Food & Dining"
    case coffeeAndBeverages = "Coffee & Beverages"
    case groceries = "Groceries"
    case fashionAndApparel = "Fashion & Apparel"
    case electronics = "Electronics"
    case booksAndStationery = "Books & Stationery"
    case transport = "Transport"
    case healthAndBeauty = "Health & Beauty"
    case entertainment = "Entertainment"
    case other = "Other"

    var id: String { rawValue }

    var label: String { rawValue }

    /// Categories exposed by `GET /shop/receipts`.
    static let shopCases: [ReceiptCategoryFilter] = [
        .coffeeAndBeverages,
        .foodAndDining,
        .electronics,
        .booksAndStationery,
        .transport
    ]
}

// MARK: - Receipt Filter

/// Single source of truth for all receipt list query state.
struct ReceiptFilter: Equatable, Sendable {
    var search: String = ""
    var category: ReceiptCategoryFilter?
    var range: ReceiptTimeFilter = .all
    var page: Int = 1
    var pageSize: Int = 20

    var hasActiveFilters: Bool {
        range != .all || category != nil || !search.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    mutating func resetPage() {
        page = 1
    }
}

// MARK: - Receipt List Result

struct ReceiptListResult: Sendable, Equatable {
    let receipts: [Receipt]
    let pagination: ReceiptPagination
}

struct ReceiptPagination: Sendable, Equatable {
    let page: Int
    let pageSize: Int
    let total: Int
    let totalPages: Int

    var hasMorePages: Bool { page < totalPages }
}

// MARK: - Receipts View Configuration

struct ReceiptsViewConfiguration: Sendable {
    let cardAudience: ReceiptCardAudience
    let searchPrompt: String
    let emptyTitle: String
    let emptyMessage: String
    let emptyFilteredMessage: String
    let categoryFilters: [ReceiptCategoryFilter]

    static let customer = ReceiptsViewConfiguration(
        cardAudience: .customer,
        searchPrompt: String(localized: "Search receipts..."),
        emptyTitle: String(localized: "No Receipts Yet"),
        emptyMessage: String(localized: "Your digital receipts will appear here after your first purchase."),
        emptyFilteredMessage: String(localized: "Try adjusting your search or filters."),
        categoryFilters: ReceiptCategoryFilter.allCases
    )

    static let shop = ReceiptsViewConfiguration(
        cardAudience: .shop,
        searchPrompt: String(localized: "Search by invoice number..."),
        emptyTitle: String(localized: "No Receipts Yet"),
        emptyMessage: String(localized: "Issued receipts from your store devices will appear here."),
        emptyFilteredMessage: String(localized: "Try adjusting your search or filters."),
        categoryFilters: ReceiptCategoryFilter.shopCases
    )
}
