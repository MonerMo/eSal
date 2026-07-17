//
//  ProfileHeader.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

// MARK: - Profile Header

struct ProfileHeader: View {
    let name: String
    let subtitle: String
    let icon: String

    var body: some View {
        VStack(spacing: Theme.Spacing.medium) {
            ZStack {
                Circle()
                    .fill(AppColors.p100.opacity(0.1))
                    .frame(width: 88, height: 88)

                Image(systemName: icon)
                    .font(.system(size: Theme.IconSize.large, weight: .medium))
                    .foregroundStyle(AppColors.p100)
            }

            VStack(spacing: Theme.Spacing.xxSmall) {
                Text(name)
                    .font(AppTypography.sectionTitle)
                    .foregroundStyle(AppColors.primaryText)

                Text(subtitle)
                    .font(AppTypography.subheadline)
                    .foregroundStyle(AppColors.secondaryText)
            }
        }
        .padding(.vertical, Theme.Spacing.medium)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }
}
