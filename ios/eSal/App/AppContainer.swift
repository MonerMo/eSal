//
//  AppContainer.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

// MARK: - App Container

/// Composition root for the entire application.
@MainActor
final class AppContainer {

    let keychain: KeychainServiceProtocol
    let sessionStore: SessionStore
    let appState: AppStateMachine
    let authService: AuthServiceProtocol
    let userRepository: UserRepositoryProtocol
    let authenticateUser: AuthenticateUserUseCase
    let bootstrapSession: BootstrapSessionUseCase
    let logout: LogoutUseCase
    let logoutService: LogoutService
    let receipts: ReceiptDependencies
    let dashboard: DashboardDependencies
    let insights: InsightsDependencies
    let nfc: NFCDependencies
    let walletService: WalletServiceProtocol
    let shopReceipts: ReceiptDependencies
    let shopDevices: ShopDeviceDependencies
    let shopDashboard: ShopDashboardDependencies
    let shopInsights: InsightsDependencies

    init() {
        let keychainService = KeychainService()
        keychain = keychainService
        sessionStore = SessionStore(keychain: keychainService)
        appState = AppStateMachine(
            phase: sessionStore.hasToken ? .restoringSession : .unauthenticated
        )

        let accessTokenProvider = KeychainTokenProvider(keychain: keychainService)
        let apiClient = APIClient(
            baseURL: APIConfig.baseURL,
            tokenProvider: { accessTokenProvider.currentToken() }
        )

        authService = AuthService(baseURL: APIConfig.baseURL)
        userRepository = APIUserRepository(client: apiClient)

        authenticateUser = AuthenticateUserUseCase(
            authService: authService,
            userRepository: userRepository,
            sessionStore: sessionStore,
            appState: appState
        )

        bootstrapSession = BootstrapSessionUseCase(
            userRepository: userRepository,
            sessionStore: sessionStore,
            appState: appState
        )

        logout = LogoutUseCase(
            sessionStore: sessionStore,
            appState: appState
        )

        logoutService = LogoutService(useCase: logout)

        receipts = ReceiptDependencies.live(client: apiClient)
        dashboard = DashboardDependencies.live(client: apiClient)
        insights = InsightsDependencies.live(client: apiClient)
        walletService = APIWalletService(client: apiClient)
        shopReceipts = ReceiptDependencies.liveShop(client: apiClient)
        shopDevices = ShopDeviceDependencies.live(client: apiClient)
        shopDashboard = ShopDashboardDependencies.live(client: apiClient)
        shopInsights = InsightsDependencies.liveShop(client: apiClient)

        let pendingNFCLinkStore = PendingNFCLinkStore()
        nfc = NFCDependencies.live(
            client: apiClient,
            pendingStore: pendingNFCLinkStore,
            logout: logout,
            appState: appState
        )
    }

    private var didBootstrap = false

    func bootstrapIfNeeded() async {
        guard !didBootstrap else { return }
        didBootstrap = true
        await bootstrapSession.execute()
    }

    func makeFlowRegistry(for session: UserSession) -> FlowRegistry {
        FlowRegistry(factories: [
            .customer: CustomerFlowFactory(
                dependencies: CustomerFlowDependencies(
                    session: session,
                    logout: logout,
                    dashboard: dashboard,
                    receipts: receipts,
                    insights: insights,
                    nfcCoordinator: nfc.coordinator,
                    walletService: walletService
                )
            ),
            .shop: ShopFlowFactory(
                dependencies: ShopFlowDependencies(
                    session: session,
                    logout: logout,
                    nfcCoordinator: nfc.coordinator,
                    walletService: walletService,
                    receipts: shopReceipts,
                    devices: shopDevices,
                    dashboard: shopDashboard,
                    insights: shopInsights
                )
            ),
        ])
    }
}
