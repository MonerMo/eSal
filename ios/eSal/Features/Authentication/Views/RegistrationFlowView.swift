//
//  RegistrationFlowView.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

// MARK: - Registration Flow View

/// Single continuous registration screen with a fixed progress bar and animated step content.
struct RegistrationFlowView: View {

    @Bindable var viewModel: RegistrationFlowViewModel
    let onDismiss: () -> Void
    let onSignIn: (String) -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                StepProgressBar(progress: viewModel.progress)
                    .padding(.horizontal, Theme.Spacing.large)
                    .padding(.top, Theme.Spacing.small)
                    .padding(.bottom, Theme.Spacing.medium)

                stepContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .id(viewModel.step)
                    .transition(stepTransition)

                if viewModel.step == .accountType {
                    signInAction
                        .padding(.horizontal, Theme.Spacing.large)
                        .padding(.vertical, Theme.Spacing.medium)
                }
            }
            .animation(.easeInOut(duration: Theme.Animation.standard), value: viewModel.step)
            .background(AppColors.background)
            .navigationTitle(String(localized: "Create Account"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                if viewModel.step == .details {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: viewModel.goBackToAccountType) {
                            Image(systemName: "chevron.left")
                                .font(.body.weight(.semibold))
                                .foregroundStyle(AppColors.p100)
                        }
                        .accessibilityLabel(String(localized: "Back"))
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var stepContent: some View {
        switch viewModel.step {
        case .accountType:
            ScrollView {
                RegisterAccountTypeView { accountType in
                    viewModel.selectAccountType(accountType)
                }
                .padding(Theme.Spacing.large)
            }

        case .details:
            if let registerViewModel = viewModel.registerViewModel,
               let accountType = viewModel.selectedAccountType {
                ScrollView {
                    RegisterView(
                        accountType: accountType,
                        viewModel: registerViewModel
                    )
                    .padding(Theme.Spacing.large)
                }
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: registerViewModel.registeredEmail) { _, _ in
                    viewModel.handleRegistrationResult(from: registerViewModel)
                }
            }

        case .success(let email):
            RegistrationSuccessView(email: email) {
                onSignIn(email)
            }
        }
    }

    private var stepTransition: AnyTransition {
        let insertionEdge: Edge = viewModel.navigationDirection == .forward ? .trailing : .leading
        let removalEdge: Edge = viewModel.navigationDirection == .forward ? .leading : .trailing

        return .asymmetric(
            insertion: .move(edge: insertionEdge).combined(with: .opacity),
            removal: .move(edge: removalEdge).combined(with: .opacity)
        )
    }

    private var signInAction: some View {
        Button(action: onDismiss) {
            HStack(spacing: Theme.Spacing.xxSmall) {
                Text(String(localized: "Already have an account?"))
                    .foregroundStyle(AppColors.secondaryText)

                Text(String(localized: "Sign In"))
                    .foregroundStyle(AppColors.p100)
                    .fontWeight(.semibold)
            }
            .font(AppTypography.headline)
        }
        .buttonStyle(.plain)
    }
}
