//
//  LoadingButton.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

// MARK: - Loading Button

struct LoadingButton: View {
    let title: String
    let isLoading: Bool
    let isEnabled: Bool
    let action: () -> Void

    init(
        _ title: String,
        isLoading: Bool = false,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isLoading = isLoading
        self.isEnabled = isEnabled
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(title)
                        .font(AppTypography.button)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.medium)
            .foregroundStyle(.white)
            .background(isEnabled && !isLoading ? AppColors.p100 : AppColors.disabled)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.medium))
        }
        .disabled(!isEnabled || isLoading)
    }
}
