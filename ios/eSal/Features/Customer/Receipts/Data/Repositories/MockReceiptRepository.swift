//
//  MockReceiptRepository.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - Mock Receipt Repository

/// Local data source for SwiftUI previews and offline development.
struct MockReceiptRepository: ReceiptRepositoryProtocol {

    private let simulatedDelay: Duration

    init(simulatedDelay: Duration = .milliseconds(600)) {
        self.simulatedDelay = simulatedDelay
    }

    func getReceipts(filter: ReceiptFilter) async throws -> ReceiptListResult {
        try await Task.sleep(for: simulatedDelay)

        return ReceiptListResult(
            receipts: [.sample],
            pagination: ReceiptPagination(
                page: filter.page,
                pageSize: filter.pageSize,
                total: 1,
                totalPages: 1
            )
        )
    }
}
