//
//  RegistrationFlowViewModel.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation
import Observation

// MARK: - Registration Flow View Model

/// Owns registration step state, progress, and the shared register form view model.
@Observable
@MainActor
final class RegistrationFlowViewModel {

    private(set) var step: RegistrationFlowStep = .accountType
    private(set) var selectedAccountType: AccountType?
    private(set) var registerViewModel: RegisterViewModel?
    private(set) var navigationDirection: FlowNavigationDirection = .forward

    let authService: AuthServiceProtocol

    var progress: Double {
        switch step {
        case .accountType:
            RegistrationProgress.accountTypeSelection
        case .details:
            RegistrationProgress.detailsForm
        case .success:
            RegistrationProgress.completed
        }
    }

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    func selectAccountType(_ accountType: AccountType) {
        navigationDirection = .forward

        if selectedAccountType != accountType {
            registerViewModel = RegisterViewModel(
                accountType: accountType,
                authService: authService
            )
        }

        selectedAccountType = accountType
        step = .details
    }

    func goBackToAccountType() {
        navigationDirection = .backward
        step = .accountType
    }

    func completeRegistration(email: String) {
        navigationDirection = .forward
        step = .success(email: email)
    }

    func handleRegistrationResult(from viewModel: RegisterViewModel) {
        guard let email = viewModel.registeredEmail else { return }
        viewModel.acknowledgeRegistration()
        completeRegistration(email: email)
    }
}
