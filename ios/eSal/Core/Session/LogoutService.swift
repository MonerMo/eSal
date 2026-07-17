//
//  LogoutService.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation
import Observation

// MARK: - Logout Service

/// Observable wrapper so views can sign out via the environment.
@Observable
@MainActor
final class LogoutService {

    private let useCase: LogoutUseCase

    init(useCase: LogoutUseCase) {
        self.useCase = useCase
    }

    func signOut() {
        useCase.execute()
    }
}
