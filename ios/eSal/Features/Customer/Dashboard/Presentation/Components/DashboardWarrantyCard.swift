//
//  DashboardWarrantyCard.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

// MARK: - Dashboard Warranty Card

struct DashboardWarrantyCard: View {
    let warranty: DashboardWarranty
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            CardView {
                VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                    Label {
                        Text(String(localized: "Nearest Warranty"))
                            .font(AppTypography.headline)
                            .foregroundStyle(AppColors.primaryText)
                    } icon: {
                        Image(systemName: "shield.lefthalf.filled")
                            .foregroundStyle(AppColors.p100)
                    }

                    Text(warranty.itemName)
                        .font(AppTypography.sectionTitle)
                        .foregroundStyle(AppColors.primaryText)
                        .lineLimit(2)

                    Text(warranty.storeName)
                        .font(AppTypography.subheadline)
                        .foregroundStyle(AppColors.secondaryText)

                    Text(
                        String(
                            localized: "Ends \(warranty.formattedWarrantyEndDate)",
                            comment: "Warranty end date label on dashboard"
                        )
                    )
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.tertiaryText)
                }
            }
        }
        .buttonStyle(.appScale)
        .accessibilityLabel("\(warranty.itemName), \(warranty.storeName)")
    }
}

#Preview {
    DashboardWarrantyCard(warranty: Dashboard.sample.nearestWarranty!) {}
        .padding()
}
