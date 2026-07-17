//
//  WarrantyRemainingLabel.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

// MARK: - Warranty Remaining Label

struct WarrantyRemainingLabel: View {
    let text: String
    let isExpired: Bool

    var body: some View {
        HStack(spacing: Theme.Spacing.xxSmall) {
            Image(systemName: "shield.lefthalf.filled")
                .font(.system(size: Theme.IconSize.small, weight: .semibold))

            Text(
                String(
                    localized: "Warranty: \(text)",
                    comment: "Remaining warranty time label"
                )
            )
            .lineLimit(2)
        }
        .font(AppTypography.caption)
        .foregroundStyle(isExpired ? AppColors.secondaryText : AppColors.p100)
        .accessibilityLabel(
            String(localized: "Warranty: \(text)", comment: "Remaining warranty time label")
        )
    }
}

#Preview {
    VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
        WarrantyRemainingLabel(text: "1 year, 3 months, 14 days", isExpired: false)
        WarrantyRemainingLabel(text: "Warranty expired", isExpired: true)
    }
    .padding()
}
