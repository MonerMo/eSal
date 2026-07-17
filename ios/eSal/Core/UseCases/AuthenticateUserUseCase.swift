//
//  AuthenticateUserUseCase.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - Authenticate User Use Case

/// Logs in, persists the token, fetches `/users/me`, and transitions to the
/// authenticated phase. Routing uses the API `accountType`, not signup UX.
@MainActor
struct AuthenticateUserUseCase {

    private let authService: AuthServiceProtocol
    private let userRepository: UserRepositoryProtocol
    private let sessionStore: SessionStore
    private let appState: AppStateMachine

    init(
        authService: AuthServiceProtocol,
        userRepository: UserRepositoryProtocol,
        sessionStore: SessionStore,
        appState: AppStateMachine
    ) {
        self.authService = authService
        self.userRepository = userRepository
        self.sessionStore = sessionStore
        self.appState = appState
    }

    func execute(email: String, password: String) async throws {
        let response = try await authService.login(
            LoginRequest(email: email, password: password)
        )
        try sessionStore.saveToken(response.accessToken)

        do {
            let user = try await userRepository.fetchCurrentUser()

            guard sessionStore.hasToken else { return }

            sessionStore.setCurrentUser(user)
            appState.setPhase(.authenticated(user))
        } catch {
            sessionStore.clear()
            throw error
        }
    }
}
