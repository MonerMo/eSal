//
//  LoadingView.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

// MARK: - Loading View

struct LoadingView: View {
    let message: String?

    init(_ message: String? = nil) {
        self.message = message
    }

    var body: some View {
        VStack(spacing: Theme.Spacing.medium) {
            ProgressView()
                .controlSize(.large)
                .tint(AppColors.p100)

            if let message {
                Text(message)
                    .font(AppTypography.subheadline)
                    .foregroundStyle(AppColors.secondaryText)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
        .accessibilityLabel(message ?? String(localized: "Loading"))
    }
}
