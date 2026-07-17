//
//  ShopDeviceCardView.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

struct ShopDeviceCardView: View {
    let device: ShopDevice

    var body: some View {
        HStack(spacing: Theme.Spacing.medium) {
            ZStack {
                Circle()
                    .fill(AppColors.p100.opacity(0.12))
                    .frame(width: 48, height: 48)

                Image(systemName: "ipad.and.iphone")
                    .font(.system(size: Theme.IconSize.medium, weight: .semibold))
                    .foregroundStyle(AppColors.p100)
            }

            VStack(alignment: .leading, spacing: Theme.Spacing.xxSmall) {
                Text(device.name)
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(1)

                Text(String(localized: "Paired \(device.formattedCreatedAt)"))
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.secondaryText)
            }

            Spacer(minLength: Theme.Spacing.xSmall)

            StatusBadge(
                title: String(localized: "Active"),
                color: AppColors.success
            )
        }
        .appCardStyle(padding: Theme.Spacing.medium)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(device.name), \(device.formattedCreatedAt)")
    }
}

#Preview {
    ShopDeviceCardView(device: .sample)
        .padding()
        .background(AppColors.background)
}
