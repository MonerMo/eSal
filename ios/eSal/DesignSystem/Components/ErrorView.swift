//
//  ErrorView.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

// MARK: - Error View

struct ErrorView: View {
    let message: String
    let isRetryable: Bool
    let retryAction: (() -> Void)?

    init(
        message: String,
        isRetryable: Bool = false,
        retryAction: (() -> Void)? = nil
    ) {
        self.message = message
        self.isRetryable = isRetryable
        self.retryAction = retryAction
    }

    var body: some View {
        VStack(spacing: Theme.Spacing.large) {
            ZStack {
                Circle()
                    .fill(AppColors.error.opacity(0.1))
                    .frame(width: 88, height: 88)

                Image(systemName: AppIcons.error)
                    .font(.system(size: Theme.IconSize.large, weight: .medium))
                    .foregroundStyle(AppColors.error)
            }

            Text(message)
                .font(AppTypography.subheadline)
                .foregroundStyle(AppColors.secondaryText)
                .multilineTextAlignment(.center)

            if isRetryable, let retryAction {
                SecondaryButton(String(localized: "Try Again"), action: retryAction)
                    .frame(maxWidth: 220)
            }
        }
        .padding(Theme.Spacing.xLarge)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
    }
}
