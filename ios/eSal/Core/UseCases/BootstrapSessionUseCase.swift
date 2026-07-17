//
//  BootstrapSessionUseCase.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - Bootstrap Session Use Case

/// Restores an existing session at launch: token in Keychain → `GET /users/me`.
@MainActor
struct BootstrapSessionUseCase {

    private let userRepository: UserRepositoryProtocol
    private let sessionStore: SessionStore
    private let appState: AppStateMachine

    init(
        userRepository: UserRepositoryProtocol,
        sessionStore: SessionStore,
        appState: AppStateMachine
    ) {
        self.userRepository = userRepository
        self.sessionStore = sessionStore
        self.appState = appState
    }

    func execute() async {
        guard sessionStore.hasToken else {
            appState.setPhase(.unauthenticated)
            return
        }

        do {
            let user = try await userRepository.fetchCurrentUser()

            // User may have signed out while this request was in flight.
            guard sessionStore.hasToken else { return }

            sessionStore.setCurrentUser(user)
            appState.setPhase(.authenticated(user))
        } catch {
            sessionStore.clear()
            appState.setPhase(.unauthenticated)
        }
    }
}
