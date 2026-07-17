//
//  APIWalletService.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - API Wallet Service

/// Downloads the signed `.pkpass` from `GET /passes/wallet` (JWT required).
struct APIWalletService: WalletServiceProtocol {

    private let client: APIClientProtocol

    init(client: APIClientProtocol) {
        self.client = client
    }

    func fetchWalletPass() async throws -> Data {
        try await client.getData("passes/wallet")
    }
}
