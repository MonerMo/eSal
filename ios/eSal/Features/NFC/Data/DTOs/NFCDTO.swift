//
//  NFCDTO.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - NFC Request DTO

struct NFCPairingRequestDTO: Encodable, Sendable {
    let pairingId: String
}

// MARK: - NFC Response DTO

struct NFCPairResponseDTO: Decodable, Sendable {
    let message: String?
}
