//
//  RegisterFormView.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

// MARK: - Register Form View

/// Declarative registration form. All logic lives in `RegisterViewModel`.
struct RegisterFormView: View {
    @Bindable var viewModel: RegisterViewModel

    @FocusState private var focusedField: String?

    private var passwordRequirements: [PasswordRequirement] {
        PasswordValidator.requirements(password: viewModel.password)
    }

    private var phoneBinding: Binding<String> {
        Binding(
            get: { viewModel.phone },
            set: { viewModel.phone = AuthValidator.filteredPhoneInput($0) }
        )
    }

    var body: some View {
        VStack(spacing: Theme.Spacing.medium) {
            AppTextField(
                title: String(localized: "Name"),
                placeholder: String(localized: "Your full name"),
                icon: AppIcons.person,
                text: $viewModel.name,
                errorMessage: viewModel.nameError,
                textContentType: .name,
                autocapitalization: .words,
                focus: $focusedField,
                focusTag: RegisterField.name.rawValue,
                submitLabel: .next,
                onSubmit: { focusedField = RegisterField.phone.rawValue }
            )

            AppTextField(
                title: String(localized: "Phone"),
                placeholder: String(localized: "05XXXXXXXX"),
                icon: AppIcons.phone,
                text: phoneBinding,
                errorMessage: viewModel.phoneError,
                keyboardType: .numberPad,
                textContentType: .telephoneNumber,
                focus: $focusedField,
                focusTag: RegisterField.phone.rawValue,
                submitLabel: .next,
                onSubmit: { focusedField = RegisterField.email.rawValue }
            )

            EmailField(
                title: String(localized: "Email"),
                text: $viewModel.email,
                errorMessage: viewModel.emailError,
                focus: $focusedField,
                focusTag: RegisterField.email.rawValue,
                submitLabel: .next,
                onSubmit: focusNextAfterEmail
            )

            if viewModel.isShop {
                AppTextField(
                    title: String(localized: "Store Name"),
                    placeholder: String(localized: "Your store name"),
                    icon: AppIcons.shop,
                    text: $viewModel.storeName,
                    errorMessage: viewModel.storeNameError,
                    autocapitalization: .words,
                    focus: $focusedField,
                    focusTag: RegisterField.storeName.rawValue,
                    submitLabel: .next,
                    onSubmit: { focusedField = RegisterField.password.rawValue }
                )
            }

            PasswordField(
                title: String(localized: "Password"),
                text: $viewModel.password,
                errorMessage: viewModel.passwordError,
                focus: $focusedField,
                focusTag: RegisterField.password.rawValue,
                submitLabel: .next,
                onSubmit: { focusedField = RegisterField.confirmPassword.rawValue }
            )

            PasswordRequirementsView(requirements: passwordRequirements)

            SecureTextField(
                title: String(localized: "Confirm Password"),
                placeholder: String(localized: "Re-enter your password"),
                text: $viewModel.confirmPassword,
                errorMessage: viewModel.confirmPasswordError,
                focus: $focusedField,
                focusTag: RegisterField.confirmPassword.rawValue,
                submitLabel: .done,
                onSubmit: submitRegistration
            )

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.error)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            LoadingButton(
                String(localized: "Create Account"),
                isLoading: viewModel.isLoading,
                isEnabled: viewModel.canSubmit
            ) {
                submitRegistration()
            }
            .padding(.top, Theme.Spacing.small)
        }
        .disabled(viewModel.isLoading)
    }

    private func focusNextAfterEmail() {
        focusedField = viewModel.isShop
            ? RegisterField.storeName.rawValue
            : RegisterField.password.rawValue
    }

    private func submitRegistration() {
        focusedField = nil
        Task { await viewModel.register() }
    }
}
