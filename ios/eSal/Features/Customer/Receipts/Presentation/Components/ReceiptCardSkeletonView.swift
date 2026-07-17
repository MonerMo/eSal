//
//  ReceiptCardSkeletonView.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

// MARK: - Receipt Card Skeleton

struct ReceiptCardSkeletonView: View {
    var body: some View {
        HStack(alignment: .top, spacing: Theme.Spacing.medium) {
            Circle()
                .fill(AppColors.disabled.opacity(0.35))
                .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
                HStack {
                    skeletonLine(width: 100, height: 14)
                    Spacer()
                    Capsule()
                        .fill(AppColors.disabled.opacity(0.35))
                        .frame(width: 72, height: 22)
                }

                skeletonLine(width: 160, height: 12)
                skeletonLine(width: 90, height: 20)
                skeletonLine(width: 180, height: 12)
            }

            RoundedRectangle(cornerRadius: Theme.Radius.small)
                .fill(AppColors.disabled.opacity(0.35))
                .frame(width: 8, height: 14)
                .padding(.top, Theme.Spacing.xxSmall)
        }
        .padding(Theme.Spacing.medium)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous))
        .redacted(reason: .placeholder)
    }

    private func skeletonLine(width: CGFloat, height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: Theme.Radius.small)
            .fill(AppColors.disabled.opacity(0.35))
            .frame(width: width, height: height)
    }
}

// MARK: - Dashboard Hero Skeleton

struct DashboardHeroSkeletonView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            RoundedRectangle(cornerRadius: Theme.Radius.small)
                .fill(AppColors.onPrimary.opacity(0.25))
                .frame(width: 180, height: 14)

            RoundedRectangle(cornerRadius: Theme.Radius.small)
                .fill(AppColors.onPrimary.opacity(0.35))
                .frame(width: 140, height: 34)
        }
        .padding(Theme.Spacing.large)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.p100.opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.xLarge))
        .redacted(reason: .placeholder)
    }
}

#Preview {
    VStack(spacing: Theme.Spacing.medium) {
        DashboardHeroSkeletonView()
        ReceiptCardSkeletonView()
    }
    .padding()
    .background(AppColors.background)
}
