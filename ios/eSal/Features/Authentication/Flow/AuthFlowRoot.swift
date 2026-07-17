//
//  AuthFlowRoot.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

// MARK: - Auth Flow Root

/// Root of the shared unauthenticated flow: Login → Register.
struct AuthFlowRoot: View {

    let authService: AuthServiceProtocol

    @State private var authRouter = AuthRouter()
    @State private var loginViewModel: LoginViewModel

    init(authService: AuthServiceProtocol, authenticateUser: AuthenticateUserUseCase) {
        self.authService = authService
        _loginViewModel = State(initialValue: LoginViewModel(authenticateUser: authenticateUser))
    }

    var body: some View {
        @Bindable var router = authRouter

        NavigationStack {
            LoginView(
                viewModel: loginViewModel,
                onRegister: { router.showRegistration() }
            )
        }
        .fullScreenCover(isPresented: $router.isRegistrationPresented) {
            RegistrationFlowContainer(
                authService: authService,
                onDismiss: { router.dismissRegistration() },
                onSignIn: { email in
                    loginViewModel.prefillEmail(email)
                    router.dismissRegistration()
                }
            )
        }
    }
}

// MARK: - Registration Flow Container

/// Hosts a fresh registration flow view model for each full-screen presentation.
private struct RegistrationFlowContainer: View {

    let authService: AuthServiceProtocol
    let onDismiss: () -> Void
    let onSignIn: (String) -> Void

    @State private var flowViewModel: RegistrationFlowViewModel

    init(
        authService: AuthServiceProtocol,
        onDismiss: @escaping () -> Void,
        onSignIn: @escaping (String) -> Void
    ) {
        self.authService = authService
        self.onDismiss = onDismiss
        self.onSignIn = onSignIn
        _flowViewModel = State(
            initialValue: RegistrationFlowViewModel(authService: authService)
        )
    }

    var body: some View {
        RegistrationFlowView(
            viewModel: flowViewModel,
            onDismiss: onDismiss,
            onSignIn: onSignIn
        )
    }
}
