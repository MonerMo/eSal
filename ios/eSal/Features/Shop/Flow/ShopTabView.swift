//
//  ShopTabView.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

struct ShopTabView: View {

    let dependencies: ShopFlowDependencies

    @Environment(\.scenePhase) private var scenePhase

    @State private var router = ShopRouter()
    @State private var profileViewModel: ProfileViewModel
    @State private var receiptsViewModel: ReceiptsViewModel
    @State private var devicesViewModel: ShopDevicesViewModel
    @State private var dashboardViewModel: ShopDashboardViewModel
    @State private var insightsViewModel: ShopInsightsViewModel

    init(dependencies: ShopFlowDependencies) {
        self.dependencies = dependencies
        _profileViewModel = State(initialValue: dependencies.makeProfileViewModel())
        _receiptsViewModel = State(initialValue: dependencies.makeReceiptsViewModel())
        _devicesViewModel = State(initialValue: dependencies.makeShopDevicesViewModel())
        _dashboardViewModel = State(initialValue: dependencies.makeShopDashboardViewModel())
        _insightsViewModel = State(initialValue: dependencies.makeShopInsightsViewModel())
    }

    var body: some View {
        @Bindable var router = router

        TabView(selection: $router.selectedTab) {
            shopTab(.dashboard, path: $router.dashboardPath) {
                ShopDashboardView(
                    viewModel: dashboardViewModel,
                    onReceiptSelected: { receipt in
                        router.showReceiptDetailsFromDashboard(receipt)
                    }
                )
            }

            shopTab(.insights) {
                InsightsView(
                    viewModel: insightsViewModel,
                    configuration: .shop
                )
            }

            shopTab(.receipts, path: $router.receiptsPath) {
                ReceiptsView(
                    viewModel: receiptsViewModel,
                    configuration: .shop,
                    onReceiptSelected: { receipt in
                        router.showReceiptDetails(receipt)
                    }
                )
            }

            shopTab(.devices) {
                ShopDevicesView(viewModel: devicesViewModel)
            }

            shopTab(.profile) {
                ShopProfileView(
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

    private func refreshData(for tab: ShopTab) async {
        switch tab {
        case .dashboard:
            await dashboardViewModel.refresh()
        case .insights:
            await insightsViewModel.refresh()
        case .receipts:
            await receiptsViewModel.refresh()
        case .devices:
            await devicesViewModel.refresh()
        case .profile:
            break
        }
    }

    private func registerNFCHandlers() {
        dependencies.nfcCoordinator.registerShopHandlers(
            NFCFlowCoordinator.ShopHandlers(
                showDevicesTab: {
                    router.selectedTab = .devices
                },
                refreshDevices: {
                    await devicesViewModel.refresh()
                }
            )
        )
    }

    private func shopTab<Content: View>(
        _ tab: ShopTab,
        path: Binding<[ShopRoute]>? = nil,
        @ViewBuilder content: () -> Content
    ) -> some View {
        Group {
            if let path {
                NavigationStack(path: path) {
                    content()
                        .navigationDestination(for: ShopRoute.self, destination: destination)
                }
            } else {
                NavigationStack {
                    content()
                }
            }
        }
        .tabItem { Label(tab.title, systemImage: tab.icon) }
        .tag(tab)
        .modifier(ShopTabNavigationTitleModifier(tab: tab))
    }

    @ViewBuilder
    private func destination(for route: ShopRoute) -> some View {
        switch route {
        case .receiptDetails(let receipt):
            ReceiptDetailsView(receipt: receipt)
        }
    }
}

private struct ShopTabNavigationTitleModifier: ViewModifier {
    let tab: ShopTab

    func body(content: Content) -> some View {
        if tab == .receipts || tab == .devices || tab == .dashboard || tab == .insights {
            content
        } else {
            content.appLargeNavigationTitle(tab.title)
        }
    }
}
