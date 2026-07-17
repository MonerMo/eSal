//
//  InsightsView.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

// MARK: - Insights View

struct InsightsView: View {

    @Bindable var viewModel: InsightsViewModel
    let configuration: InsightsViewConfiguration

    init(
        viewModel: InsightsViewModel,
        configuration: InsightsViewConfiguration = .customer
    ) {
        self.viewModel = viewModel
        self.configuration = configuration
    }

    var body: some View {
        content
            .background(AppColors.background)
            .appLargeNavigationTitle(String(localized: "Insights"))
            .task {
                if !viewModel.hasLoaded {
                    await viewModel.load()
                }
            }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.showsFullScreenLoading {
            insightsSkeleton
        } else if viewModel.showsFullScreenError, let message = viewModel.errorMessage {
            ErrorView(message: message, isRetryable: true) {
                Task { await viewModel.load() }
            }
        } else {
            insightsContent
        }
    }

    private var insightsSkeleton: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.large) {
                RoundedRectangle(cornerRadius: Theme.Radius.medium)
                    .fill(AppColors.disabled.opacity(0.2))
                    .frame(height: 32)

                if configuration.showsTotalCard {
                    DashboardHeroSkeletonView()
                }

                ReceiptCardSkeletonView()
                ReceiptCardSkeletonView()
            }
            .padding(Theme.Spacing.large)
        }
    }

    private var insightsContent: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.large) {
                    rangeSelector

                    if configuration.showsTotalCard {
                        totalCard
                    }

                    if viewModel.showsInlineLoading {
                        inlineLoading
                    } else if viewModel.showsInlineError, let message = viewModel.errorMessage {
                        ErrorView(message: message, isRetryable: true) {
                            Task { await viewModel.refresh() }
                        }
                    } else if viewModel.showsEmptyCategories {
                        emptyState
                    } else {
                        breakdownSection
                    }
                }
                .padding(Theme.Spacing.large)
            }
        }
        .refreshable {
            await viewModel.refresh()
        }
    }

    private var rangeSelector: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
            Text(String(localized: "Time Range"))
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.secondaryText)

            Picker("", selection: rangeBinding) {
                ForEach(InsightsRange.allCases) { range in
                    Text(range.label).tag(range)
                }
            }
            .pickerStyle(.segmented)
            .accessibilityLabel(String(localized: "Time range"))
        }
    }

    private var rangeBinding: Binding<InsightsRange> {
        Binding(
            get: { viewModel.selectedRange },
            set: { newRange in
                Task { await viewModel.selectRange(newRange) }
            }
        )
    }

    private var totalCard: some View {
        StatCard(
            icon: AppIcons.analytics,
            title: configuration.totalCardTitle,
            value: viewModel.formattedTotalSpending
        )
    }

    private var breakdownSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
            SectionHeader(
                configuration.sectionTitle,
                subtitle: configuration.sectionSubtitle(for: viewModel.selectedRange)
            )

            CardView {
                InsightsChartView(
                    categories: viewModel.categories,
                    totalSpending: viewModel.totalSpending
                )
            }
        }
    }

    private var emptyState: some View {
        EmptyState(
            icon: AppIcons.analytics,
            title: configuration.emptyTitle,
            message: configuration.emptyMessage
        )
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.Spacing.medium)
    }

    private var inlineLoading: some View {
        ProgressView()
            .tint(AppColors.p100)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.large)
    }
}

#Preview {
    NavigationStack {
        InsightsView(
            viewModel: InsightsViewModel(
                getInsights: GetInsightsUseCase(repository: MockInsightsRepository()),
                logout: LogoutUseCase(
                    sessionStore: SessionStore(keychain: KeychainService()),
                    appState: AppStateMachine()
                )
            )
        )
    }
}
