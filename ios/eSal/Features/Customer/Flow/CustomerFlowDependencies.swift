//
//  CustomerFlowDependencies.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - Customer Flow Dependencies

/// Dependency subgraph for the customer application flow.
@MainActor
struct CustomerFlowDependencies {
    let session: UserSession
    let logout: LogoutUseCase
    let dashboard: DashboardDependencies
    let receipts: ReceiptDependencies
    let insights: InsightsDependencies
    let nfcCoordinator: NFCFlowCoordinator
    let walletService: WalletServiceProtocol

    func makeDashboardViewModel() -> DashboardViewModel {
        dashboard.makeDashboardViewModel(logout: logout)
    }

    func makeReceiptsViewModel() -> ReceiptsViewModel {
        receipts.makeReceiptsViewModel()
    }

    func makeInsightsViewModel() -> InsightsViewModel {
        insights.makeInsightsViewModel(logout: logout)
    }

    func makeProfileViewModel() -> ProfileViewModel {
        ProfileViewModel(walletService: walletService)
    }
}
