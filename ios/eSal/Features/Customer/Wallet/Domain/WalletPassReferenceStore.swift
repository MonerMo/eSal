//
//  WalletPassReferenceStore.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - Wallet Pass Reference

struct WalletPassReference: Codable, Sendable, Equatable {
    let passTypeIdentifier: String
    let serialNumber: String
}

// MARK: - Wallet Pass Reference Store

/// Persists pass identifiers so Wallet presence can be checked without refetching from the server.
struct WalletPassReferenceStore: Sendable {
    private let defaults: UserDefaults
    private let key = "walletPassReference"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> WalletPassReference? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(WalletPassReference.self, from: data)
    }

    func save(_ reference: WalletPassReference) {
        guard let data = try? JSONEncoder().encode(reference) else { return }
        defaults.set(data, forKey: key)
    }

    func clear() {
        defaults.removeObject(forKey: key)
    }
}
