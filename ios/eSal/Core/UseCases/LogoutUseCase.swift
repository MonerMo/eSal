//
//  LogoutUseCase.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - Logout Use Case

/// Clears credentials and returns the app to the authentication flow.
@MainActor
struct LogoutUseCase {

    private let sessionStore: SessionStore
    private let appState: AppStateMachine

    init(sessionStore: SessionStore, appState: AppStateMachine) {
        self.sessionStore = sessionStore
        self.appState = appState
    }

    func execute() {
        sessionStore.clear()
        appState.setPhase(.unauthenticated)
    }
}
