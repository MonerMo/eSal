//
//  Insights.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - Insights Range

enum InsightsRange: String, CaseIterable, Identifiable, Sendable {
    case thisMonth = "thisMonth"
    case lastMonth = "lastMonth"
    case threeMonths = "3months"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .thisMonth:
            String(localized: "This Month")
        case .lastMonth:
            String(localized: "Last Month")
        case .threeMonths:
            String(localized: "3 Months")
        }
    }

    var sectionSubtitle: String {
        switch self {
        case .thisMonth:
            String(localized: "Where your money went this month.")
        case .lastMonth:
            String(localized: "Where your money went last month.")
        case .threeMonths:
            String(localized: "Where your money went in the last 3 months.")
        }
    }

    var shopSectionSubtitle: String {
        switch self {
        case .thisMonth:
            String(localized: "Revenue breakdown this month.")
        case .lastMonth:
            String(localized: "Revenue breakdown last month.")
        case .threeMonths:
            String(localized: "Revenue breakdown for the last 3 months.")
        }
    }
}

// MARK: - Insights

/// Spending insights aggregate from `GET /insights`.
struct Insights: Sendable, Equatable {
    let range: InsightsRange
    let totalSpending: Decimal
    let categories: [InsightsCategorySpending]
}

// MARK: - Category Spending

struct InsightsCategorySpending: Identifiable, Hashable, Sendable {
    let category: String
    let total: Decimal

    var id: String { category }

    var formattedTotal: String {
        Receipt.formatMoney(total)
    }

    func fraction(of totalSpending: Decimal) -> Double {
        guard totalSpending > 0 else { return 0 }
        let ratio = total / totalSpending
        return min(max(NSDecimalNumber(decimal: ratio).doubleValue, 0), 1)
    }

    var systemIcon: String {
        InsightsCategoryIcon.symbol(for: category)
    }
}

// MARK: - Category Icon

enum InsightsCategoryIcon {
    static func symbol(for category: String) -> String {
        let normalized = category.lowercased()

        if normalized.contains("food") || normalized.contains("dining") {
            return "fork.knife"
        }
        if normalized.contains("coffee") || normalized.contains("beverage") || normalized.contains("matcha") {
            return "cup.and.saucer.fill"
        }
        if normalized.contains("grocer") {
            return "cart.fill"
        }
        if normalized.contains("fashion") || normalized.contains("apparel") {
            return "tshirt.fill"
        }
        if normalized.contains("electronic") {
            return "desktopcomputer"
        }
        if normalized.contains("book") || normalized.contains("stationery") {
            return "book.fill"
        }
        if normalized.contains("transport") {
            return "car.fill"
        }
        if normalized.contains("health") || normalized.contains("beauty") {
            return "heart.fill"
        }
        if normalized.contains("entertainment") {
            return "film.fill"
        }
        if normalized.contains("other") || normalized.contains("uncategorized") {
            return "ellipsis.circle.fill"
        }

        return "tag.fill"
    }
}

// MARK: - Preview Sample

extension Insights {
    static let sample = Insights(
        range: .thisMonth,
        totalSpending: 560.40,
        categories: [
            InsightsCategorySpending(category: "Electronics", total: 228.85),
            InsightsCategorySpending(category: "Groceries", total: 331.55)
        ]
    )
}

// MARK: - Insights List Scope

enum InsightsListScope: Sendable {
    case customer
    case shop

    var path: String {
        switch self {
        case .customer: "insights"
        case .shop: "shop/insights"
        }
    }
}

// MARK: - Insights View Configuration

struct InsightsViewConfiguration: Sendable {
    enum Audience: Sendable {
        case customer
        case shop
    }

    let audience: Audience
    let totalCardTitle: String
    let sectionTitle: String
    let showsTotalCard: Bool
    let emptyTitle: String
    let emptyMessage: String

    static let customer = InsightsViewConfiguration(
        audience: .customer,
        totalCardTitle: String(localized: "Total Spending"),
        sectionTitle: String(localized: "Spending by Category"),
        showsTotalCard: false,
        emptyTitle: String(localized: "No Spending Found"),
        emptyMessage: String(localized: "No spending found for this period.")
    )

    static let shop = InsightsViewConfiguration(
        audience: .shop,
        totalCardTitle: String(localized: "Total Revenue"),
        sectionTitle: String(localized: "Revenue by Category"),
        showsTotalCard: true,
        emptyTitle: String(localized: "No Revenue Found"),
        emptyMessage: String(localized: "No revenue found for this period.")
    )

    func sectionSubtitle(for range: InsightsRange) -> String {
        switch audience {
        case .customer:
            range.sectionSubtitle
        case .shop:
            range.shopSectionSubtitle
        }
    }
}
