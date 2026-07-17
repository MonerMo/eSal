//
//  RegisterView.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

// MARK: - Register View

/// Registration form content for a specific account type.
struct RegisterView: View {

    let accountType: AccountType
    @Bindable var viewModel: RegisterViewModel

    var body: some View {
        VStack(spacing: Theme.Spacing.large) {
            SectionHeader(
                accountType.title,
                subtitle: String(localized: "Enter your details")
            )

            RegisterFormView(viewModel: viewModel)
        }
    }
}
