//
//  SessionStore.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation
import Observation

// MARK: - Session Store

/// Owns the access token (Keychain) and the cached authenticated user profile.
@Observable
@MainActor
final class SessionStore {

    private(set) var currentUser: UserSession?

    private let keychain: KeychainServiceProtocol

    init(keychain: KeychainServiceProtocol) {
        self.keychain = keychain
    }

    var accessToken: String? {
        keychain.read(SessionKeys.accessToken)
    }

    var hasToken: Bool {
        accessToken != nil
    }

    func saveToken(_ token: String) throws {
        try keychain.save(token, for: SessionKeys.accessToken)
    }

    func setCurrentUser(_ user: UserSession) {
        currentUser = user
    }

    func clear() {
        currentUser = nil
        do {
            try keychain.delete(SessionKeys.accessToken)
        } catch {
            #if DEBUG
            print("SessionStore: failed to delete token from Keychain — \(error)")
            #endif
        }
    }
}
