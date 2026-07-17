//
//  StatusBadge.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

// MARK: - Status Badge

struct StatusBadge: View {
    let title: String
    let color: Color

    var body: some View {
        Text(title)
            .font(AppTypography.caption)
            .foregroundStyle(color)
            .padding(.horizontal, Theme.Spacing.small)
            .padding(.vertical, Theme.Spacing.xxSmall)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
            .accessibilityLabel(title)
    }
}

// MARK: - Receipt Status

extension StatusBadge {
    static func receipt(_ receipt: Receipt) -> StatusBadge {
        StatusBadge(title: receipt.statusDisplay, color: color(for: receipt.status))
    }

    static func warranty(for receipt: Receipt) -> StatusBadge? {
        guard let title = receipt.formattedWarrantyRemaining else { return nil }
        let color = receipt.isWarrantyExpired ? AppColors.secondaryText : AppColors.p100
        return StatusBadge(title: title, color: color)
    }

    private static func color(for status: String) -> Color {
        switch status.uppercased() {
        case "ASSIGNED":
            AppColors.success
        case "PENDING":
            AppColors.warning
        default:
            AppColors.secondaryText
        }
    }
}
