//
//  DashboardView.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

// MARK: - Dashboard Content Tab

private enum DashboardContentTab: String, CaseIterable, Identifiable {
    case warranties
    case recentReceipts

    var id: String { rawValue }

    var title: String {
        switch self {
        case .warranties:
            String(localized: "Warranties")
        case .recentReceipts:
            String(localized: "Recent Receipts")
        }
    }
}

// MARK: - Dashboard View

struct DashboardView: View {

    @Environment(CustomerRouter.self) private var router
    @Bindable var viewModel: DashboardViewModel

    @State private var selectedContentTab: DashboardContentTab = .recentReceipts

    var body: some View {
        content
            .background(AppColors.background)
            .appLargeNavigationTitle(navigationTitleText)
            .task {
                if !viewModel.hasLoaded {
                    await viewModel.load()
                }
            }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.showsFullScreenLoading {
            dashboardSkeleton
        } else if viewModel.showsFullScreenError, let message = viewModel.errorMessage {
            ErrorView(message: message, isRetryable: true) {
                Task { await viewModel.load() }
            }
        } else {
            dashboardContent
        }
    }

    // MARK: - Skeleton

    private var dashboardSkeleton: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.large) {
                DashboardHeroSkeletonView()

                RoundedRectangle(cornerRadius: Theme.Radius.medium)
                    .fill(AppColors.disabled.opacity(0.2))
                    .frame(height: 32)

                VStack(spacing: Theme.Spacing.medium) {
                    ForEach(0..<3, id: \.self) { _ in
                        ReceiptCardSkeletonView()
                    }
                }
            }
            .padding(Theme.Spacing.large)
        }
    }

    // MARK: - Content

    private var dashboardContent: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.large) {
                    // TODO: Re-enable warranty alert banner when ready.
                    // if let warranty = viewModel.nearestWarranty {
                    //     warrantyAlertBanner(warranty)
                    // }

                    monthlySpendingCard

                    if viewModel.showsSmartOffers {
                        smartOffersSection
                    }

                    segmentedControl
                    contentArea
                }
                .padding(Theme.Spacing.large)
                .animation(.easeInOut(duration: Theme.Animation.standard), value: selectedContentTab)
            }
        }
        .refreshable {
            await viewModel.refresh()
        }
    }

    // MARK: - Warranty Alert

    /*
    private func warrantyAlertBanner(_ warranty: DashboardWarranty) -> some View {
        Button {
            router.showReceiptDetailsFromDashboard(warranty.receipt)
        } label: {
            HStack(spacing: Theme.Spacing.small) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: Theme.IconSize.medium))
                    .foregroundStyle(AppColors.error)

                Text(warranty.alertMessage)
                    .font(AppTypography.subheadline)
                    .foregroundStyle(AppColors.primaryText)
                    .multilineTextAlignment(.leading)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, Theme.Spacing.medium)
            .padding(.vertical, Theme.Spacing.small)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColors.error.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(warranty.alertMessage)
    }
    */

    // MARK: - Navigation Title

    private var navigationTitleText: String {
        if viewModel.firstName.isEmpty {
            String(localized: "Hello")
        } else {
            "Hello, \(viewModel.firstName)"
        }
    }

    // MARK: - Spending Card

    private var monthlySpendingCard: some View {
        StatCard(
            icon: AppIcons.analytics,
            title: String(localized: "Total Spending (This Month)"),
            value: viewModel.formattedMonthlySpending
        )
    }

    // MARK: - Smart Offers

    private var smartOffersSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
            SectionHeader(String(localized: "Smart Offers"))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Theme.Spacing.medium) {
                    ForEach(viewModel.smartOffers) { offer in
                        SmartOfferCard(offer: offer)
                    }
                }
                .padding(.vertical, Theme.Spacing.xxSmall)
            }
        }
    }

    // MARK: - Segmented Control

    private var segmentedControl: some View {
        Picker("", selection: $selectedContentTab) {
            ForEach(DashboardContentTab.allCases) { tab in
                Text(tab.title).tag(tab)
            }
        }
        .pickerStyle(.segmented)
        .accessibilityLabel(String(localized: "Dashboard content"))
    }

    // MARK: - Content Area

    @ViewBuilder
    private var contentArea: some View {
        switch selectedContentTab {
        case .recentReceipts:
            recentReceiptsContent
        case .warranties:
            warrantiesContent
        }
    }

    private var recentReceiptsContent: some View {
        Group {
            if viewModel.showsEmptyReceipts {
                EmptyState(
                    icon: AppIcons.receipts,
                    title: String(localized: "No Receipts Yet"),
                    message: String(localized: "Your recent purchases will appear here.")
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.Spacing.medium)
            } else {
                VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
                    SectionHeader(
                        String(localized: "Recent Receipts"),
                        subtitle: String(localized: "Your latest purchases at a glance.")
                    )

                    VStack(spacing: Theme.Spacing.medium) {
                        ForEach(Array(viewModel.recentReceipts.enumerated()), id: \.element.id) { index, receipt in
                            Button {
                                router.showReceiptDetailsFromDashboard(receipt)
                            } label: {
                                ReceiptCardView(receipt: receipt, audience: .customer)
                            }
                            .buttonStyle(.plain)
                            .appListAppearAnimation(index: index)
                        }
                    }
                }
            }
        }
        .transition(.opacity.combined(with: .move(edge: .trailing)))
    }

    private var warrantiesContent: some View {
        Group {
            if let warranty = viewModel.nearestWarranty {
                VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
                    SectionHeader(
                        String(localized: "Active Warranty"),
                        subtitle: String(localized: "Coverage ending soon.")
                    )

                    DashboardWarrantyCard(warranty: warranty) {
                        router.showReceiptDetailsFromDashboard(warranty.receipt)
                    }
                }
            } else {
                EmptyState(
                    icon: "shield.lefthalf.filled",
                    title: String(localized: "No Active Warranties"),
                    message: String(localized: "Warranties from your purchases will appear here.")
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.Spacing.medium)
            }
        }
        .transition(.opacity.combined(with: .move(edge: .leading)))
    }
}

#Preview {
    NavigationStack {
        DashboardView(
            viewModel: DashboardViewModel(
                getDashboard: GetDashboardUseCase(repository: MockDashboardRepository()),
                logout: LogoutUseCase(
                    sessionStore: SessionStore(keychain: KeychainService()),
                    appState: AppStateMachine()
                )
            )
        )
    }
    .environment(CustomerRouter())
}
