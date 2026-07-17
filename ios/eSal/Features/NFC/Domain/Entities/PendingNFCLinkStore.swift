//
//  PendingNFCLinkStore.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - Pending NFC Link Store

@MainActor
final class PendingNFCLinkStore {

    private let defaults: UserDefaults
    private let storageKey = "pending_nfc_link_intent"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func store(_ intent: NFCLinkIntent) {
        guard let data = try? JSONEncoder().encode(intent) else { return }
        defaults.set(data, forKey: storageKey)
    }

    func peek() -> NFCLinkIntent? {
        guard let data = defaults.data(forKey: storageKey) else { return nil }
        return try? JSONDecoder().decode(NFCLinkIntent.self, from: data)
    }

    func consume() -> NFCLinkIntent? {
        guard let intent = peek() else { return nil }
        clear()
        return intent
    }

    func clear() {
        defaults.removeObject(forKey: storageKey)
    }
}
