//
//  RegistrationSuccessView.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

// MARK: - Registration Success View

/// Success content shown at the end of the registration flow.
struct RegistrationSuccessView: View {

    let email: String
    let onSignIn: () -> Void

    var body: some View {
        VStack(spacing: Theme.Spacing.xLarge) {
            Spacer()

            Image(systemName: AppIcons.checkmark)
                .font(.system(size: Theme.IconSize.hero))
                .foregroundStyle(AppColors.success)

            VStack(spacing: Theme.Spacing.small) {
                Text(String(localized: "Account Created"))
                    .font(AppTypography.title)
                    .foregroundStyle(AppColors.primaryText)

                Text(String(localized: "Your account has been created successfully. Sign in to continue."))
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.secondaryText)
                    .multilineTextAlignment(.center)

                Text(email)
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.p100)
            }

            PrimaryButton(String(localized: "Sign In Now"), action: onSignIn)

            Spacer()
        }
        .padding(Theme.Spacing.large)
    }
}
