//
//  ReceiptFilterChip.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

// MARK: - Receipt Filter Chip

struct ReceiptFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTypography.caption)
                .foregroundStyle(isSelected ? AppColors.onPrimary : AppColors.primaryText)
                .padding(.horizontal, Theme.Spacing.medium)
                .padding(.vertical, Theme.Spacing.small)
                .background(isSelected ? AppColors.p100 : AppColors.cardBackground)
                .clipShape(Capsule())
                .overlay {
                    if !isSelected {
                        Capsule()
                            .stroke(AppColors.border, lineWidth: 1)
                    }
                }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    ScrollView(.horizontal) {
        HStack {
            ReceiptFilterChip(title: "All", isSelected: true, action: {})
            ReceiptFilterChip(title: "Electronics", isSelected: false, action: {})
        }
    }
    .padding()
}
