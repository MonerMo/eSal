//
//  KeychainTokenProvider.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - Keychain Token Provider

/// Supplies the current access token from Keychain on every authenticated request.
struct KeychainTokenProvider: Sendable {

    private let keychain: KeychainService
    private let tokenKey: String

    init(
        keychain: KeychainService,
        tokenKey: String = SessionKeys.accessToken
    ) {
        self.keychain = keychain
        self.tokenKey = tokenKey
    }

    func currentToken() -> String? {
        keychain.read(tokenKey)
    }
}
