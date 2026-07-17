//
//  LoginViewModel.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation
import Observation

// MARK: - Login View Model

@Observable
@MainActor
final class LoginViewModel {

    var email = ""
    var password = ""

    var emailError: String?
    var passwordError: String?
    var errorMessage: String?
    var isLoading = false

    private let authenticateUser: AuthenticateUserUseCase

    init(authenticateUser: AuthenticateUserUseCase) {
        self.authenticateUser = authenticateUser
    }

    func prefillEmail(_ email: String) {
        self.email = email
        emailError = nil
        errorMessage = nil
    }

    func login() async {
        guard validate(), !isLoading else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await authenticateUser.execute(
                email: email.trimmed,
                password: password
            )
        } catch let error as AuthError {
            handleAuthError(error)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func handleAuthError(_ error: AuthError) {
        errorMessage = error.localizedDescription
    }

    private func validate() -> Bool {
        emailError = nil
        passwordError = nil
        errorMessage = nil
        var isValid = true

        if !AuthValidator.isValidEmail(email) {
            emailError = String(localized: "Enter a valid email address")
            isValid = false
        }
        if password.isEmpty {
            passwordError = String(localized: "Password is required")
            isValid = false
        }
        return isValid
    }
}
