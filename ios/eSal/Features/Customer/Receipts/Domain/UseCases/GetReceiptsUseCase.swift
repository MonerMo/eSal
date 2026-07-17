//
//  GetReceiptsUseCase.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - Get Receipts Use Case

struct GetReceiptsUseCase: Sendable {

    private let repository: ReceiptRepositoryProtocol

    init(repository: ReceiptRepositoryProtocol) {
        self.repository = repository
    }

    func execute(filter: ReceiptFilter) async throws -> ReceiptListResult {
        try await repository.getReceipts(filter: filter)
    }
}
