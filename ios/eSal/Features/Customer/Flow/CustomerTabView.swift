//
//  CustomerTabView.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

// MARK: - Customer Tab View

struct CustomerTabView: View {

    let dependencies: CustomerFlowDependencies

    @Environment(\.scenePhase) private var scenePhase

    @State private var router = CustomerRouter()
    @State private var dashboardViewModel: DashboardViewModel
    @State private var receiptsViewModel: ReceiptsViewModel
    @State private var insightsViewModel: InsightsViewModel
    @State private var profileViewModel: ProfileViewModel

    init(dependencies: CustomerFlowDependencies) {
        self.dependencies = dependencies
        _dashboardViewModel = State(initialValue: dependencies.makeDashboardViewModel())
        _receiptsViewModel = State(initialValue: dependencies.makeReceiptsViewModel())
        _insightsViewModel = State(initialValue: dependencies.makeInsightsViewModel())
        _profileViewModel = State(initialValue: dependencies.makeProfileViewModel())
    }

    var body: some View {
        @Bindable var router = router

        TabView(selection: $router.selectedTab) {
            tab(.dashboard, path: $router.dashboardPath) {
                DashboardView(viewModel: dashboardViewModel)
            }
            tab(.receipts, path: $router.receiptsPath) {
                ReceiptsView(
                    viewModel: receiptsViewModel,
                    onReceiptSelected: { receipt in
                        router.showReceiptDetails(receipt)
                    }
                )
            }
            tab(.insights, path: $router.insightsPath) {
                InsightsView(viewModel: insightsViewModel)
            }
            tab(.profile, path: $router.profilePath) {
                ProfileView(
                    session: dependencies.session,
                    viewModel: profileViewModel
                ) {
                    dependencies.logout.execute()
                }
            }
        }
        .appTabBarStyle()
        .environment(router)
        .onAppear {
            registerNFCHandlers()

            Task {
                await dependencies.nfcCoordinator.resumePendingIfNeeded()
            }
        }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            guard !dependencies.nfcCoordinator.isProcessing else { return }
            Task { await refreshData(for: router.selectedTab) }
        }
        .onChange(of: router.selectedTab) { _, tab in
            guard !dependencies.nfcCoordinator.isProcessing else { return }
            Task { await refreshData(for: tab) }
        }
    }

    // MARK: - Refresh

    private func refreshData(for tab: CustomerTab) async {
        switch tab {
        case .dashboard:
            await dashboardViewModel.refresh()
        case .receipts:
            await receiptsViewModel.refresh()
        case .insights:
            await insightsViewModel.refresh()
        case .profile:
            break
        }
    }

    private func registerNFCHandlers() {
        dependencies.nfcCoordinator.registerCustomerHandlers(
            NFCFlowCoordinator.CustomerHandlers(
                handleClaimedReceipt: { receipt in
                    receiptsViewModel.upsert(receipt)
                    dashboardViewModel.upsertRecentReceipt(receipt)

                    await router.openClaimedReceipt(receipt)

                    await receiptsViewModel.refreshPreserving(receipt)
                    await dashboardViewModel.refreshPreservingRecentReceipt(receipt)
                }
            )
        )
    }

    // MARK: - Tab Builder

    private func tab<Content: View>(
        _ tab: CustomerTab,
        path: Binding<[CustomerRoute]>,
        @ViewBuilder content: () -> Content
    ) -> some View {
        NavigationStack(path: path) {
            content()
                .navigationDestination(for: CustomerRoute.self, destination: destination)
        }
        .tabItem { Label(tab.title, systemImage: tab.icon) }
        .tag(tab)
    }

    @ViewBuilder
    private func destination(for route: CustomerRoute) -> some View {
        switch route {
        case .receiptDetails(let receipt):
            ReceiptDetailsView(receipt: receipt)
        }
    }
}
