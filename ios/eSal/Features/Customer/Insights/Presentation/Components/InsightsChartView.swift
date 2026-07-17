//
//  InsightsChartView.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

// MARK: - Insights Chart View

struct InsightsChartView: View {

    let categories: [InsightsCategorySpending]
    let totalSpending: Decimal

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(categories.enumerated()), id: \.element.id) { index, category in
                categoryRow(category)
                    .appListAppearAnimation(index: index)

                if index < categories.count - 1 {
                    Divider()
                        .padding(.vertical, Theme.Spacing.medium)
                }
            }
        }
    }

    private func categoryRow(_ category: InsightsCategorySpending) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            HStack(alignment: .center, spacing: Theme.Spacing.medium) {
                categoryIcon(category)

                VStack(alignment: .leading, spacing: Theme.Spacing.xxSmall) {
                    Text(category.category)
                        .font(AppTypography.headline)
                        .foregroundStyle(AppColors.primaryText)
                        .lineLimit(2)

                    Text(percentageLabel(for: category))
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.secondaryText)
                }

                Spacer(minLength: Theme.Spacing.small)

                Text(category.formattedTotal)
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.p100)
                    .multilineTextAlignment(.trailing)
            }

            progressBar(for: category)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel(for: category))
    }

    private func categoryIcon(_ category: InsightsCategorySpending) -> some View {
        Image(systemName: category.systemIcon)
            .font(.system(size: Theme.IconSize.small, weight: .semibold))
            .foregroundStyle(AppColors.p100)
            .frame(width: 40, height: 40)
            .background(AppColors.p100.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous))
    }

    private func progressBar(for category: InsightsCategorySpending) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(AppColors.border.opacity(0.28))

                Capsule()
                    .fill(AppColors.p100)
                    .frame(width: max(geometry.size.width * category.fraction(of: totalSpending), 8))
            }
        }
        .frame(height: 10)
        .animation(.easeOut(duration: Theme.Animation.standard), value: category.fraction(of: totalSpending))
    }

    private func percentageLabel(for category: InsightsCategorySpending) -> String {
        let percentage = Int((category.fraction(of: totalSpending) * 100).rounded())
        return String(localized: "\(percentage)% of total")
    }

    private func accessibilityLabel(for category: InsightsCategorySpending) -> String {
        "\(category.category), \(category.formattedTotal), \(percentageLabel(for: category))"
    }
}

#Preview {
    CardView {
        InsightsChartView(
            categories: Insights.sample.categories,
            totalSpending: Insights.sample.totalSpending
        )
    }
    .padding()
}
