//
//  AccountTypeButton.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

// MARK: - Account Type Button

/// A large, tappable card used to pick an account type during registration.
struct AccountTypeButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            Button(action: action) {
                CardView(style: .primary) {
                    HStack(spacing: Theme.Spacing.medium) {
                        Image(systemName: icon)
                            .font(.system(size: Theme.IconSize.large))
                            .foregroundStyle(.white)
                            .frame(width: 52)

                        VStack(alignment: .leading, spacing: Theme.Spacing.xxSmall) {
                            Text(title)
                                .font(AppTypography.headline)
                                .foregroundStyle(.white)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundStyle(.white.opacity(0.9))
                    }
                }
            }
            .buttonStyle(.plain)

            Text(subtitle)
                .font(AppTypography.subheadline)
                .foregroundStyle(AppColors.secondaryText)
                .multilineTextAlignment(.leading)
                .padding(.leading, 18)
        }
    }
}

#Preview {
    RegisterAccountTypeView(onSelect: { _ in })
}
