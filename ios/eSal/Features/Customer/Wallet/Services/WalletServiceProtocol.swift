//
//  WalletServiceProtocol.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - Wallet Service Protocol

protocol WalletServiceProtocol: Sendable {
    func fetchWalletPass() async throws -> Data
}

// MARK: - Wallet Service Error

enum WalletServiceError: LocalizedError {
    case invalidPass

    var errorDescription: String? {
        switch self {
        case .invalidPass:
            String(localized: "The wallet pass could not be read. Please try again.")
        }
    }
}
