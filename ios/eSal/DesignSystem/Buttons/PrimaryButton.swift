//
//  PrimaryButton.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

// MARK: - Primary Button

struct PrimaryButton: View {
    let title: String
    let isEnabled: Bool
    let action: () -> Void

    init(_ title: String, isEnabled: Bool = true, action: @escaping () -> Void) {
        self.title = title
        self.isEnabled = isEnabled
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTypography.button)
                .frame(maxWidth: .infinity)
                .frame(minHeight: Theme.Layout.minTapTarget)
                .foregroundStyle(AppColors.onPrimary)
                .background(isEnabled ? AppColors.p100 : AppColors.disabled)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous))
        }
        .buttonStyle(.appScale)
        .disabled(!isEnabled)
        .accessibilityLabel(title)
    }
}

#Preview {
    PrimaryButton("Continue") {}
        .padding()
}
