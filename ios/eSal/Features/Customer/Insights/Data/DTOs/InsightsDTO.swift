//
//  InsightsDTO.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - Insights DTO

struct InsightsDTO: Decodable, Sendable {
    let range: String
    let totalSpending: DecimalString?
    let totalRevenue: DecimalString?
    let categories: [InsightsCategoryDTO]

    var resolvedTotal: DecimalString {
        totalSpending ?? totalRevenue ?? DecimalString(0)
    }
}

struct InsightsCategoryDTO: Decodable, Sendable {
    let category: String?
    let total: DecimalString
}
