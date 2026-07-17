//
//  StatCard.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

// MARK: - Stat Card Style

enum StatCardStyle {
    case primary
    case surface
}

// MARK: - Stat Card

struct StatCard: View {
    let icon: String?
    let title: String
    let value: String
    var style: StatCardStyle = .primary

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
            if let icon {
                HStack(spacing: Theme.Spacing.small) {
                    Image(systemName: icon)
                        .font(.system(size: Theme.IconSize.medium, weight: .semibold))
                        .foregroundStyle(labelColor)

                    Text(title)
                        .font(AppTypography.subheadline)
                        .foregroundStyle(labelColor)
                }
            } else {
                Text(title)
                    .font(AppTypography.subheadline)
                    .foregroundStyle(labelColor)
            }

            Text(value)
                .font(AppTypography.statValue)
                .foregroundStyle(valueColor)
                .minimumScaleFactor(0.75)
                .lineLimit(1)
        }
        .padding(Theme.Spacing.xLarge)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(background)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.xLarge, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(value)")
    }

    private var labelColor: Color {
        switch style {
        case .primary:
            AppColors.onPrimary.opacity(0.92)
        case .surface:
            AppColors.secondaryText
        }
    }

    private var valueColor: Color {
        switch style {
        case .primary:
            AppColors.onPrimary
        case .surface:
            AppColors.primaryText
        }
    }

    @ViewBuilder
    private var background: some View {
        switch style {
        case .primary:
            AppColors.p100
        case .surface:
            AppColors.cardBackground
        }
    }
}

#Preview {
    VStack(spacing: Theme.Spacing.medium) {
        StatCard(
            icon: AppIcons.analytics,
            title: "Total Spending (This Month)",
            value: "SAR 1,234.50"
        )
        StatCard(
            icon: nil,
            title: "Receipts This Month",
            value: "42",
            style: .surface
        )
    }
    .padding()
    .background(AppColors.background)
}
