//
//  WarrantyRemaining.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - Warranty Remaining

enum WarrantyRemaining {

    static func format(until endDate: Date, from referenceDate: Date = .now) -> String {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: referenceDate)
        let end = calendar.startOfDay(for: endDate)

        guard end > start else {
            return String(localized: "Warranty expired")
        }

        let components = calendar.dateComponents([.year, .month, .day], from: start, to: end)
        let years = max(components.year ?? 0, 0)
        let months = max(components.month ?? 0, 0)
        let days = max(components.day ?? 0, 0)

        var parts: [String] = []

        if years > 0 {
            parts.append(unitLabel(value: years, singular: String(localized: "year"), plural: String(localized: "years")))
        }
        if months > 0 {
            parts.append(unitLabel(value: months, singular: String(localized: "month"), plural: String(localized: "months")))
        }
        if days > 0 || parts.isEmpty {
            parts.append(unitLabel(value: days, singular: String(localized: "day"), plural: String(localized: "days")))
        }

        return parts.joined(separator: " and ")
    }

    private static func unitLabel(value: Int, singular: String, plural: String) -> String {
        value == 1 ? "1 \(singular)" : "\(value) \(plural)"
    }
}

// MARK: - Receipt Warranty

extension Receipt {
    /// Soonest warranty end date among line items, if any.
    var nearestWarrantyEndDate: Date? {
        items.compactMap(\.warrantyEndDate).min()
    }

    var formattedWarrantyRemaining: String? {
        guard let nearestWarrantyEndDate else { return nil }
        return WarrantyRemaining.format(until: nearestWarrantyEndDate)
    }

    var isWarrantyExpired: Bool {
        guard let nearestWarrantyEndDate else { return false }
        return Calendar.current.startOfDay(for: nearestWarrantyEndDate) <= Calendar.current.startOfDay(for: .now)
    }

    var hasWarranty: Bool {
        formattedWarrantyRemaining != nil
    }
}

// MARK: - Line Item Warranty

extension ReceiptLineItem {
    var formattedWarrantyRemaining: String? {
        guard let warrantyEndDate else { return nil }
        return WarrantyRemaining.format(until: warrantyEndDate)
    }

    var isWarrantyExpired: Bool {
        guard let warrantyEndDate else { return false }
        return Calendar.current.startOfDay(for: warrantyEndDate) <= Calendar.current.startOfDay(for: .now)
    }
}
