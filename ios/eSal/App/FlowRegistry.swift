//
//  FlowRegistry.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

// MARK: - Flow Factory

protocol FlowFactory {
  @MainActor
  func makeRoot(session: UserSession) -> AnyView
}

// MARK: - Flow Registry

/// Maps `AccountType` to an independent application flow (Open/Closed).
@MainActor
final class FlowRegistry {

    private let factories: [AccountType: FlowFactory]

    init(factories: [AccountType: FlowFactory]) {
        self.factories = factories
    }

    @ViewBuilder
    func makeRoot(for session: UserSession) -> some View {
        if session.accountType.isSupported,
           let factory = factories[session.accountType] {
            factory.makeRoot(session: session)
        } else {
            UnsupportedAccountView(accountType: session.accountType)
        }
    }
}

// MARK: - Unsupported Account

struct UnsupportedAccountView: View {
    let accountType: AccountType

    @Environment(LogoutService.self) private var logoutService

    var body: some View {
        VStack(spacing: Theme.Spacing.large) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: Theme.IconSize.hero))
                .foregroundStyle(AppColors.warning)

            Text("Account Not Supported")
                .font(AppTypography.title)
                .foregroundStyle(AppColors.primaryText)

            Text("This account type (\(accountType.title)) is not available in this version of the app.")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.secondaryText)
                .multilineTextAlignment(.center)

            SecondaryButton(String(localized: "Sign Out")) {
                logoutService.signOut()
            }
        }
        .padding(Theme.Spacing.large)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
    }
}
