//
//  NFCRemoteDataSource.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - NFC Remote Data Source

struct NFCRemoteDataSource: Sendable {

    private let client: APIClientProtocol

    init(client: APIClientProtocol) {
        self.client = client
    }

    func claimReceipt(pairingId: String) async throws -> ReceiptDTO {
        try await client.postDecoded(
            "receipts/claim/nfc",
            body: NFCPairingRequestDTO(pairingId: pairingId)
        )
    }

    func pairDevice(pairingId: String) async throws -> NFCPairResponseDTO? {
        let data = try await client.post(
            "devices/pair/nfc",
            body: NFCPairingRequestDTO(pairingId: pairingId)
        )

        guard !data.isEmpty else { return nil }

        return try JSONDecoder.api().decode(NFCPairResponseDTO.self, from: data)
    }
}
