//
//  ReceiptRepository.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - Receipt Repository

struct ReceiptRepository: ReceiptRepositoryProtocol {

    private let remoteDataSource: ReceiptRemoteDataSource

    init(remoteDataSource: ReceiptRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }

    func getReceipts(filter: ReceiptFilter) async throws -> ReceiptListResult {
        let response = try await remoteDataSource.fetchReceipts(filter: filter)
        return ReceiptMapper.map(response)
    }
}
