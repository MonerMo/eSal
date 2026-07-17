//
//  ShopDashboardView.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

struct ShopDashboardView: View {

    @Bindable var viewModel: ShopDashboardViewModel
    let onReceiptSelected: (Receipt) -> Void

    var body: some View {
        content
            .background(AppColors.background)
            .appLargeNavigationTitle(viewModel.navigationTitle)
            .task {
                if !viewModel.hasLoaded {
                    await viewModel.loadDashboard()
                }
            }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.showsFullScreenLoading {
            dashboardSkeleton
        } else if viewModel.showsFullScreenError, let message = viewModel.errorMessage {
            ErrorView(message: message, isRetryable: true) {
                Task { await viewModel.loadDashboard() }
            }
        } else {
            dashboardContent
        }
    }

    private var dashboardSkeleton: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.large) {
                DashboardHeroSkeletonView()

                VStack(spacing: Theme.Spacing.medium) {
                    ForEach(0..<3, id: \.self) { _ in
                        ReceiptCardSkeletonView()
                    }
                }
            }
            .padding(Theme.Spacing.large)
        }
    }

    private var dashboardContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.large) {
                revenueCard
                recentReceiptsSection
            }
            .padding(Theme.Spacing.large)
        }
        .refreshable {
            await viewModel.refresh()
        }
    }

    private var revenueCard: some View {
        StatCard(
            icon: AppIcons.analytics,
            title: String(localized: "Total Revenue This Month"),
            value: viewModel.formattedRevenue
        )
    }

    private var recentReceiptsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
            SectionHeader(
                String(localized: "Recent Receipts"),
                subtitle: viewModel.formattedReceiptCount
            )

            if viewModel.showsEmptyReceipts {
                EmptyState(
                    icon: AppIcons.receipts,
                    title: String(localized: "No Receipts Yet"),
                    message: String(localized: "Issued receipts from your store devices will appear here.")
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.Spacing.medium)
            } else {
                VStack(spacing: Theme.Spacing.medium) {
                    ForEach(Array(viewModel.recentReceipts.enumerated()), id: \.element.id) { index, receipt in
                        Button {
                            onReceiptSelected(receipt)
                        } label: {
                            ReceiptCardView(receipt: receipt, style: .shopSummary, audience: .shop)
                        }
                        .buttonStyle(.plain)
                        .appListAppearAnimation(index: index)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ShopDashboardView(
            viewModel: ShopDashboardViewModel(
                getDashboard: GetShopDashboardUseCase(
                    repository: ShopDashboardRepository(
                        remoteDataSource: ShopDashboardRemoteDataSource(
                            client: APIClient(
                                baseURL: APIConfig.baseURL,
                                tokenProvider: { nil }
                            )
                        )
                    )
                ),
                logout: LogoutUseCase(
                    sessionStore: SessionStore(keychain: KeychainService()),
                    appState: AppStateMachine()
                )
            ),
            onReceiptSelected: { _ in }
        )
    }
}
