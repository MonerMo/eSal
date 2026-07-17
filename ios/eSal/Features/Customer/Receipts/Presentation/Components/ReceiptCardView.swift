//
//  ReceiptCardView.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

// MARK: - Receipt Card Style

enum ReceiptCardStyle {
    case standard
    case shopSummary
}

// MARK: - Receipt Card Audience

enum ReceiptCardAudience {
    case customer
    case shop
}

// MARK: - Receipt Card View

struct ReceiptCardView: View {
    let receipt: Receipt
    var style: ReceiptCardStyle = .standard
    var audience: ReceiptCardAudience = .customer

    var body: some View {
        HStack(alignment: .top, spacing: Theme.Spacing.medium) {
            leadingIcon

            VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
                headerRow
                storeRow
                totalRow
                metadataRow
            }

            Image(systemName: "chevron.right")
                .font(.system(size: Theme.IconSize.small, weight: .semibold))
                .foregroundStyle(AppColors.secondaryText)
                .padding(.top, Theme.Spacing.xxSmall)
        }
        .appCardStyle(padding: Theme.Spacing.medium)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAddTraits(.isButton)
    }

    private var headerRow: some View {
        HStack(alignment: .center, spacing: Theme.Spacing.small) {
            Text(receipt.receiptNumber)
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.primaryText)
                .lineLimit(1)

            Spacer(minLength: Theme.Spacing.xSmall)

            headerBadge
        }
    }

    @ViewBuilder
    private var headerBadge: some View {
        switch audience {
        case .shop:
            StatusBadge.receipt(receipt)
        case .customer:
            if let badge = StatusBadge.warranty(for: receipt) {
                badge
            }
        }
    }

    private var storeRow: some View {
        Text(receipt.storeName)
            .font(AppTypography.subheadline)
            .foregroundStyle(AppColors.secondaryText)
            .lineLimit(2)
    }

    private var totalRow: some View {
        Text(receipt.formattedTotal)
            .font(AppTypography.statValue)
            .foregroundStyle(AppColors.p100)
            .lineLimit(1)
            .minimumScaleFactor(0.75)
    }

    private var metadataRow: some View {
        HStack(spacing: Theme.Spacing.xSmall) {
            Text(receipt.paymentMethodDisplay)
                .lineLimit(1)

            Text("•")
                .accessibilityHidden(true)

            Text(receipt.formattedDate)
                .lineLimit(1)
        }
        .font(AppTypography.caption)
        .foregroundStyle(AppColors.tertiaryText)
    }

    @ViewBuilder
    private var leadingIcon: some View {
        switch style {
        case .standard:
            StoreAvatarView(name: receipt.storeName, logoURL: receipt.storeLogoURL)
        case .shopSummary:
            ZStack {
                Circle()
                    .fill(AppColors.p100.opacity(0.12))
                    .frame(width: 48, height: 48)

                Image(systemName: "doc.text")
                    .font(.system(size: Theme.IconSize.medium, weight: .semibold))
                    .foregroundStyle(AppColors.p100)
            }
        }
    }

    private var accessibilityLabel: String {
        var parts = [
            receipt.receiptNumber,
            receipt.storeName,
            receipt.formattedTotal,
            receipt.paymentMethodDisplay,
            receipt.formattedDate
        ]

        switch audience {
        case .shop:
            parts.append(receipt.statusDisplay)
        case .customer:
            if let warrantyRemaining = receipt.formattedWarrantyRemaining {
                parts.append(String(localized: "Warranty: \(warrantyRemaining)"))
            }
        }

        return parts.joined(separator: ", ")
    }
}

#Preview {
    VStack(spacing: Theme.Spacing.medium) {
        ReceiptCardView(receipt: .sample, audience: .customer)
        ReceiptCardView(receipt: .sample, style: .shopSummary, audience: .shop)
    }
    .padding()
    .background(AppColors.background)
}
