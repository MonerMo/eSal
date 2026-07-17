//
//  ReceiptDetailsView.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

// MARK: - Receipt Details View

struct ReceiptDetailsView: View {

    let receipt: Receipt

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.large) {
                receiptPaper
            }
            .padding(Theme.Spacing.large)
            .appContentWidth()
        }
        .background(AppColors.background)
        .navigationTitle(String(localized: "Receipt Details"))
        .navigationBarTitleDisplayMode(.inline)
        .appNavigationBarStyle()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(
                    item: "\(receipt.storeName) • \(receipt.formattedDate)"
                ) {
                    Image(systemName: "square.and.arrow.up")
                }
                .accessibilityLabel(String(localized: "Share receipt"))
            }
        }
    }
}

// MARK: - Receipt Paper

private extension ReceiptDetailsView {

    var receiptPaper: some View {
        CardView {
            VStack(spacing: Theme.Spacing.large) {
                receiptHeader
                Divider()
                receiptItems
                Divider()
                receiptSummary
            }
        }
    }
}

// MARK: - Header

private extension ReceiptDetailsView {

    var receiptHeader: some View {
        VStack(spacing: Theme.Spacing.medium) {
            StoreAvatarView(
                name: receipt.storeName,
                logoURL: receipt.storeLogoURL,
                size: 72
            )

            VStack(spacing: Theme.Spacing.xSmall) {
                Text(receipt.storeName)
                    .font(AppTypography.sectionTitle)
                    .foregroundStyle(AppColors.primaryText)
                    .multilineTextAlignment(.center)

                HStack(spacing: Theme.Spacing.small) {
                    Text(receipt.receiptNumber)
                        .font(AppTypography.subheadline)
                        .foregroundStyle(AppColors.secondaryText)

                    StatusBadge.receipt(receipt)
                }

                Text(receipt.formattedDate)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.tertiaryText)

            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Items

private extension ReceiptDetailsView {

    var receiptItems: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
            SectionHeader(String(localized: "Purchased Items"))

            VStack(spacing: Theme.Spacing.medium) {
                ForEach(receipt.items) { item in
                    itemRow(item)

                    if item.id != receipt.items.last?.id {
                        Divider()
                    }
                }
            }
        }
    }

    func itemRow(_ item: ReceiptLineItem) -> some View {
        HStack(alignment: .top, spacing: Theme.Spacing.medium) {
            VStack(alignment: .leading, spacing: Theme.Spacing.xxSmall) {
                Text(item.name)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.primaryText)

                Text(String(localized: "Qty \(item.quantityDisplay)"))
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.secondaryText)

                if let warrantyRemaining = item.formattedWarrantyRemaining {
                    WarrantyRemainingLabel(
                        text: warrantyRemaining,
                        isExpired: item.isWarrantyExpired
                    )
                }
            }

            Spacer()

            Text(item.formattedLineTotal())
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.primaryText)
        }
    }
}

// MARK: - Summary

private extension ReceiptDetailsView {

    var receiptSummary: some View {
        VStack(spacing: Theme.Spacing.medium) {
            infoRow(title: String(localized: "Subtotal"), value: Receipt.formatMoney(receipt.subtotal))
            infoRow(title: String(localized: "VAT"), value: receipt.formattedVAT)

            Divider()

            infoRow(
                title: String(localized: "Total"),
                value: receipt.formattedTotal,
                isTotal: true
            )

            Divider()

            receiptInfo

            Divider()

            receiptFooter
        }
    }

    var receiptInfo: some View {
        VStack(spacing: Theme.Spacing.medium) {
            infoRow(title: String(localized: "Payment Method"), value: receipt.paymentMethodDisplay)
            infoRow(title: String(localized: "Tax ID"), value: receipt.taxIdDisplay)
            infoRow(title: String(localized: "Invoice No."), value: receipt.receiptNumber)
        }
    }

    var receiptFooter: some View {
        VStack(spacing: Theme.Spacing.medium) {
            if let invoiceNumber = receipt.invoiceNumber,
               let barcode = generateBarcode(from: invoiceNumber) {
                barcode
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 64)
                    .accessibilityHidden(true)
            }

            Text(String(localized: "Show this receipt for returns or exchanges."))
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, Theme.Spacing.small)
    }
}

// MARK: - Helpers

private extension ReceiptDetailsView {

    @ViewBuilder
    func infoRow(title: String, value: String, isTotal: Bool = false) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(isTotal ? AppTypography.headline : AppTypography.body)
                .foregroundStyle(isTotal ? AppColors.primaryText : AppColors.secondaryText)

            Spacer()

            Text(value)
                .font(isTotal ? AppTypography.statValue : AppTypography.body)
                .foregroundStyle(isTotal ? AppColors.p100 : AppColors.primaryText)
                .multilineTextAlignment(.trailing)
        }
    }
}

#Preview {
    NavigationStack {
        ReceiptDetailsView(receipt: .sample)
    }
}
