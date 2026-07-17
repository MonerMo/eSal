//
//  PairDeviceViaNFCUseCase.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - Pair Device Via NFC Use Case

struct PairDeviceViaNFCUseCase: Sendable {

    private let repository: NFCRepositoryProtocol

    init(repository: NFCRepositoryProtocol) {
        self.repository = repository
    }

    func execute(pairingId: String) async throws -> NFCPairResult {
        try await repository.pairDevice(pairingId: pairingId)
    }
}
