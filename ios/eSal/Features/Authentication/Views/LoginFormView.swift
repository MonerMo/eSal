//
//  LoginFormView.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

// MARK: - Login Form View

/// Declarative login form. All logic lives in `LoginViewModel`.
struct LoginFormView: View {
    @Bindable var viewModel: LoginViewModel

    @FocusState private var focusedField: String?

    var body: some View {
        VStack(spacing: Theme.Spacing.medium) {
            EmailField(
                title: String(localized: "Enter your email"),
                text: $viewModel.email,
                errorMessage: viewModel.emailError,
                focus: $focusedField,
                focusTag: "loginEmail",
                submitLabel: .next,
                onSubmit: { focusedField = "loginPassword" }
            )

            PasswordField(
                title: String(localized: "Enter your password"),
                text: $viewModel.password,
                errorMessage: viewModel.passwordError,
                focus: $focusedField,
                focusTag: "loginPassword",
                submitLabel: .go,
                onSubmit: submitLogin
            )

            Button(action: {}) {
                Text(String(localized: "Forgot password?"))
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.p100)
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, alignment: .trailing)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.error)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            LoadingButton(
                String(localized: "Login"),
                isLoading: viewModel.isLoading
            ) {
                submitLogin()
            }
            .padding(.top, Theme.Spacing.small)
        }
        .disabled(viewModel.isLoading)
    }

    private func submitLogin() {
        focusedField = nil
        Task { await viewModel.login() }
    }
}
