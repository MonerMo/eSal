//
//  SecondaryButton.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

// MARK: - Secondary Button

struct SecondaryButton: View {
    let title: String
    let action: () -> Void

    init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTypography.button)
                .frame(maxWidth: .infinity)
                .frame(minHeight: Theme.Layout.minTapTarget)
                .foregroundStyle(AppColors.p100)
                .background(AppColors.cardBackground)
                .overlay {
                    RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                        .stroke(AppColors.p100.opacity(0.85), lineWidth: 1)
                }
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous))
        }
        .buttonStyle(.appScale)
        .accessibilityLabel(title)
    }
}
