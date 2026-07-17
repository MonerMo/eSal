//
//  ShopFlowDependencies.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

@MainActor
struct ShopFlowDependencies {
    let session: UserSession
    let logout: LogoutUseCase
    let nfcCoordinator: NFCFlowCoordinator
    let walletService: WalletServiceProtocol
    let receipts: ReceiptDependencies
    let devices: ShopDeviceDependencies
    let dashboard: ShopDashboardDependencies
    let insights: InsightsDependencies

    func makeProfileViewModel() -> ProfileViewModel {
        ProfileViewModel(walletService: walletService)
    }

    func makeReceiptsViewModel() -> ReceiptsViewModel {
        receipts.makeReceiptsViewModel()
    }

    func makeShopDevicesViewModel() -> ShopDevicesViewModel {
        devices.makeShopDevicesViewModel()
    }

    func makeShopDashboardViewModel() -> ShopDashboardViewModel {
        dashboard.makeShopDashboardViewModel(logout: logout)
    }

    func makeShopInsightsViewModel() -> ShopInsightsViewModel {
        insights.makeInsightsViewModel(logout: logout)
    }
}
