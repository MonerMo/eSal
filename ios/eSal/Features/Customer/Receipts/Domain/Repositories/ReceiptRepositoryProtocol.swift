//
//  ReceiptRepositoryProtocol.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - Receipt Repository

protocol ReceiptRepositoryProtocol: Sendable {
    func getReceipts(filter: ReceiptFilter) async throws -> ReceiptListResult
}
