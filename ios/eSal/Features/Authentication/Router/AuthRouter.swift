//
//  AuthRouter.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation
import Observation

// MARK: - Auth Router

/// Owns presentation state for the authentication flow.
@Observable
@MainActor
final class AuthRouter {

    var isRegistrationPresented = false

    func showRegistration() {
        isRegistrationPresented = true
    }

    func dismissRegistration() {
        isRegistrationPresented = false
    }
}
