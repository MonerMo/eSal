//
//  LoginView.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

// MARK: - Login View

/// First screen for unauthenticated users.
struct LoginView: View {

    @Bindable var viewModel: LoginViewModel
    let onRegister: () -> Void

    @Environment(\.openURL) private var openURL

    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: Theme.Spacing.xLarge) {
                header

                LoginFormView(viewModel: viewModel)

                SecondaryButton(String(localized: "Create an Account"), action: onRegister)

                Spacer()
            }
            .padding(Theme.Spacing.large)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Button(action: openLanguageSettingsInApp) {
                HStack(spacing: Theme.Spacing.xxSmall) {
                    Image(systemName: "globe")
                }
                .font(AppTypography.headline)
            }
            .buttonStyle(.plain)
            .padding(.leading, Theme.Spacing.large)
            .padding(.top, Theme.Spacing.medium)
        }
        .background(AppColors.background)
        .navigationBarHidden(true)
    }

    private var header: some View {
        VStack(spacing: Theme.Spacing.medium) {
            Text("eSal")
                .font(AppTypography.logo)
                .foregroundStyle(AppColors.primaryText)
                .padding(.top, Theme.Spacing.medium)

            Text("Welcome back")
                .font(AppTypography.welcome)
                .foregroundStyle(AppColors.secondaryText)
        }
        .padding(.bottom, Theme.Spacing.medium)
    }

    private func openLanguageSettingsInApp() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        openURL(url)
    }
}
