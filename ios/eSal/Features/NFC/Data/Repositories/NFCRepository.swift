//
//  NFCRepository.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - NFC Repository

struct NFCRepository: NFCRepositoryProtocol {

    private let remoteDataSource: NFCRemoteDataSource

    init(remoteDataSource: NFCRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }

    func claimReceipt(pairingId: String) async throws -> NFCClaimResult {
        let dto = try await remoteDataSource.claimReceipt(pairingId: pairingId)
        return NFCClaimResult(receipt: ReceiptMapper.map(dto))
    }

    func pairDevice(pairingId: String) async throws -> NFCPairResult {
        let response = try await remoteDataSource.pairDevice(pairingId: pairingId)
        return NFCPairResult(message: response?.message)
    }
}
