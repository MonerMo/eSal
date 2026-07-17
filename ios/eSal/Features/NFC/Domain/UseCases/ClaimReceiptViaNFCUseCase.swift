//
//  ClaimReceiptViaNFCUseCase.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - Claim Receipt Via NFC Use Case

struct ClaimReceiptViaNFCUseCase: Sendable {

    private let repository: NFCRepositoryProtocol

    init(repository: NFCRepositoryProtocol) {
        self.repository = repository
    }

    func execute(pairingId: String) async throws -> NFCClaimResult {
        try await repository.claimReceipt(pairingId: pairingId)
    }
}
