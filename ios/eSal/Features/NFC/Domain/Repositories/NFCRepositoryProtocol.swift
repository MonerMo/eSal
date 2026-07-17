//
//  NFCRepositoryProtocol.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - NFC Repository Protocol

protocol NFCRepositoryProtocol: Sendable {
    func claimReceipt(pairingId: String) async throws -> NFCClaimResult
    func pairDevice(pairingId: String) async throws -> NFCPairResult
}
