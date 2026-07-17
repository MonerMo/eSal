//
//  ReceiptDependencies.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - Receipt Dependencies

/// Composition helper for the Receipts feature.
struct ReceiptDependencies: Sendable {
    let getReceipts: GetReceiptsUseCase

    static func live(client: APIClientProtocol) -> ReceiptDependencies {
        makeDependencies(client: client, scope: .customer)
    }

    static func liveShop(client: APIClientProtocol) -> ReceiptDependencies {
        makeDependencies(client: client, scope: .shop)
    }

    func makeReceiptsViewModel() -> ReceiptsViewModel {
        ReceiptsViewModel(getReceipts: getReceipts)
    }

    private static func makeDependencies(
        client: APIClientProtocol,
        scope: ReceiptListScope
    ) -> ReceiptDependencies {
        let remoteDataSource = ReceiptRemoteDataSource(client: client, scope: scope)
        let repository = ReceiptRepository(remoteDataSource: remoteDataSource)
        return ReceiptDependencies(getReceipts: GetReceiptsUseCase(repository: repository))
    }
}
