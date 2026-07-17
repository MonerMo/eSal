//
//  ShopProfileView.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

struct ShopProfileView: View {

    let session: UserSession
    let viewModel: ProfileViewModel
    let onSignOut: () -> Void

    @State private var showSignOutConfirmation = false
    @State private var toast: ToastData?

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: Theme.Spacing.large) {
                    ProfileHeader(
                        name: session.name,
                        subtitle: session.email,
                        icon: AppIcons.shop
                    )

                    CardView {
                        VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
                            infoRow(String(localized: "Name"), value: session.name)
                            infoRow(String(localized: "Email"), value: session.email)
                            infoRow(String(localized: "Phone"), value: session.phone)
                            infoRow(String(localized: "Account"), value: session.accountType.title)
                        }
                    }

                    WalletPassButton(viewModel: viewModel)

                    SecondaryButton(String(localized: "Sign Out")) {
                        showSignOutConfirmation = true
                    }
                }
                .padding(Theme.Spacing.large)
            }
        }
        .background(AppColors.background)
        .confirmationDialog(
            String(localized: "Sign Out"),
            isPresented: $showSignOutConfirmation,
            titleVisibility: .visible
        ) {
            Button(String(localized: "Sign Out"), role: .destructive) {
                onSignOut()
            }
            Button(String(localized: "Cancel"), role: .cancel) {}
        } message: {
            Text(String(localized: "Are you sure you want to sign out?"))
        }
        .toast($toast)
        .onChange(of: viewModel.errorMessage) { _, message in
            guard let message else { return }
            toast = ToastData(message: message, style: .error)
            viewModel.clearError()
        }
    }

    private func infoRow(_ label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xxSmall) {
            Text(label)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.secondaryText)
            Text(value)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.primaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
