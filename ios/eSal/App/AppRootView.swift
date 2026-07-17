//
//  AppRootView.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

// MARK: - App Root View

/// Top-level switch driven by `AppPhase`. Routes to the correct product flow
/// using `accountType` from `GET /users/me`, not signup UX.
struct AppRootView: View {

    @Bindable var appState: AppStateMachine
    @Bindable var nfcCoordinator: NFCFlowCoordinator
    let container: AppContainer

    var body: some View {
        Group {
            switch appState.phase {
            case .unauthenticated:
                AuthFlowRoot(
                    authService: container.authService,
                    authenticateUser: container.authenticateUser
                )

            case .restoringSession:
                SessionLoadingView()

            case .authenticated(let session):
                container.makeFlowRegistry(for: session).makeRoot(for: session)
            }
        }
        .id(appState.phase)
        .appScreenStyle()
        .appDefaultTextColor()
        .environment(container.logoutService)
        .environment(container.sessionStore)
        .overlay {
            if nfcCoordinator.isProcessing {
                ZStack {
                    Color.black.opacity(0.15)
                        .ignoresSafeArea()

                    LoadingView(nfcCoordinator.processingMessage)
                        .padding(Theme.Spacing.large)
                        .background(AppColors.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.large))
                }
            }
        }
        .overlay {
            if let message = nfcCoordinator.retryableErrorMessage {
                ZStack {
                    AppColors.background.ignoresSafeArea()

                    VStack(spacing: Theme.Spacing.medium) {
                        ErrorView(message: message, isRetryable: true) {
                            Task { await nfcCoordinator.retry() }
                        }

                        SecondaryButton(String(localized: "Dismiss")) {
                            nfcCoordinator.dismissRetryError()
                        }
                        .padding(.horizontal, Theme.Spacing.large)
                    }
                }
            }
        }
        .toast($nfcCoordinator.toast)
        .onChange(of: appState.phase) { _, newPhase in
            guard case .authenticated = newPhase else { return }
            Task { await nfcCoordinator.resumePendingIfNeeded() }
        }
    }
}
