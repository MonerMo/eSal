//
//  FlowNavigationToolbar.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

// MARK: - Profile Actions Toolbar

/// Settings and sign-out actions for the profile screen navigation bar.
struct ProfileActionsToolbar: ToolbarContent {
    let onSettingsTap: () -> Void
    let onLogoutTap: () -> Void

    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            HStack(spacing: Theme.Spacing.small) {
                Button(action: onSettingsTap) {
                    Image(systemName: AppIcons.settings)
                }
                .accessibilityLabel(String(localized: "Settings"))

                Button(action: onLogoutTap) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .foregroundStyle(AppColors.error)
                }
                .accessibilityLabel(String(localized: "Sign Out"))
            }
        }
    }
}

// MARK: - Main Flow Navigation Bar

extension View {

    /// Applies a consistent inline navigation title for a main flow tab screen.
    ///
    /// - Parameter title: The inline navigation bar title.
    func mainFlowNavigationBar(title: String) -> some View {
        navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
    }
}
