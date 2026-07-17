//
//  InsightsMapper.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - Insights Mapper

enum InsightsMapper {

    static func map(_ dto: InsightsDTO, requestedRange: InsightsRange) -> Insights {
        Insights(
            range: mapRange(dto.range, fallback: requestedRange),
            totalSpending: dto.resolvedTotal.value,
            categories: dto.categories.map(mapCategory)
        )
    }

    private static func mapRange(_ rawValue: String, fallback: InsightsRange) -> InsightsRange {
        InsightsRange(rawValue: rawValue) ?? fallback
    }

    private static func mapCategory(_ dto: InsightsCategoryDTO) -> InsightsCategorySpending {
        let name = dto.category?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        return InsightsCategorySpending(
            category: name.isEmpty ? String(localized: "Unknown") : name,
            total: max(dto.total.value, 0)
        )
    }
}
