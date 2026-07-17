//
//  ReceiptRemoteDataSource.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - Receipt Remote Data Source

struct ReceiptRemoteDataSource: Sendable {

    private let client: APIClientProtocol
    private let scope: ReceiptListScope

    init(client: APIClientProtocol, scope: ReceiptListScope = .customer) {
        self.client = client
        self.scope = scope
    }

    func fetchReceipts(filter: ReceiptFilter) async throws -> ReceiptListResponseDTO {
        try await client.get(
            scope.path,
            queryItems: Self.queryItems(for: filter, scope: scope)
        )
    }

    private static func queryItems(
        for filter: ReceiptFilter,
        scope: ReceiptListScope
    ) -> [URLQueryItem] {
        var items = [
            URLQueryItem(name: "page", value: String(filter.page)),
            URLQueryItem(name: "pageSize", value: String(filter.pageSize))
        ]

        let trimmedSearch = filter.search.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedSearch.isEmpty {
            let searchParameter = scope == .shop ? "invoiceNo" : "search"
            items.append(URLQueryItem(name: searchParameter, value: trimmedSearch))
        }

        if let category = filter.category {
            items.append(URLQueryItem(name: "category", value: category.rawValue))
        }

        if filter.range != .all {
            items.append(URLQueryItem(name: "range", value: filter.range.rawValue))
        }

        return items
    }
}
