//
//  RegisterViewModel.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation
import Observation

// MARK: - Register View Model

/// Handles registration input, validation, and the sign-up call.
///
/// The API returns no token, so on success the user is *not* logged in.
/// `registeredEmail` signals the view to navigate to the success screen.
@Observable
@MainActor
final class RegisterViewModel {

    // MARK: - Configuration

    let accountType: AccountType

    var isShop: Bool { accountType == .shop }

    // MARK: - Input

    var name = ""
    var phone = ""
    var email = ""
    var password = ""
    var confirmPassword = ""
    var storeName = ""

    // MARK: - Output

    var nameError: String?
    var phoneError: String?
    var emailError: String?
    var passwordError: String?
    var confirmPasswordError: String?
    var storeNameError: String?
    var errorMessage: String?
    var isLoading = false
    private(set) var registeredEmail: String?

    var canSubmit: Bool {
        !isLoading && !name.isBlank && !phone.isBlank && !email.isBlank && !password.isBlank
            && !confirmPassword.isBlank && (!isShop || !storeName.isBlank)
    }

    // MARK: - Dependencies

    private let authService: AuthServiceProtocol

    // MARK: - Initialization

    init(accountType: AccountType, authService: AuthServiceProtocol) {
        self.accountType = accountType
        self.authService = authService
    }

    // MARK: - Actions

    func register() async {
        guard validate() else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        let request = SignUpRequest(
            email: email.trimmed,
            password: password,
            name: name.trimmed,
            phone: phone.trimmed,
            accountType: accountType,
            storeName: isShop ? storeName.trimmed : nil
        )

        do {
            try await authService.signUp(request)
            registeredEmail = email.trimmed
        } catch let error as AuthError {
            handleAuthError(error)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Called by the view after it has reacted to a successful registration.
    func acknowledgeRegistration() {
        registeredEmail = nil
        clear()
    }

    // MARK: - Validation

    private func validate() -> Bool {
        nameError = nil
        phoneError = nil
        emailError = nil
        passwordError = nil
        confirmPasswordError = nil
        storeNameError = nil
        errorMessage = nil
        var isValid = true

        if name.isBlank {
            nameError = String(localized: "Name is required.")
            isValid = false
        }
        if !AuthValidator.isValidPhone(phone) {
            phoneError = String(localized: "Phone must start with 05 and be exactly 10 digits.")
            isValid = false
        }
        if !AuthValidator.isValidEmail(email) {
            emailError = String(localized: "Enter a valid email address.")
            isValid = false
        }

        if !PasswordValidator.isValid(password: password) {
            passwordError = String(localized: "Password does not meet the requirements.")
            isValid = false
        }
        if confirmPassword != password {
            confirmPasswordError = String(localized: "Passwords do not match.")
            isValid = false
        }

        if isShop, storeName.isBlank {
            storeNameError = String(localized: "Store name is required.")
            isValid = false
        }
        return isValid
    }

    private func handleAuthError(_ error: AuthError) {
        switch error {
        case .emailAlreadyInUse:
            emailError = error.localizedDescription
        case .validationErrors, .network, .invalidResponse, .invalidCredentials, .server:
            errorMessage = error.localizedDescription
        }
    }

    private func clear() {
        name = ""
        phone = ""
        email = ""
        password = ""
        confirmPassword = ""
        storeName = ""
    }
}
