//
//  NFCLinkIntent.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - NFC Link Intent

struct NFCLinkIntent: Codable, Sendable, Hashable, Equatable {
    let pairingId: String
    let mode: NFCLinkMode

    var deduplicationKey: String {
        "\(mode.rawValue)-\(pairingId)"
    }
}

// MARK: - NFC Claim Result

struct NFCClaimResult: Sendable, Equatable {
    let receipt: Receipt
}

// MARK: - NFC Pair Result

struct NFCPairResult: Sendable, Equatable {
    let message: String?
}
