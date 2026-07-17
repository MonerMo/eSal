//
//  NFCDependencies.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - NFC Dependencies

@MainActor
struct NFCDependencies {
    let coordinator: NFCFlowCoordinator

    static func live(
        client: APIClientProtocol,
        pendingStore: PendingNFCLinkStore,
        logout: LogoutUseCase,
        appState: AppStateMachine
    ) -> NFCDependencies {
        let remoteDataSource = NFCRemoteDataSource(client: client)
        let repository = NFCRepository(remoteDataSource: remoteDataSource)

        let coordinator = NFCFlowCoordinator(
            claimReceipt: ClaimReceiptViaNFCUseCase(repository: repository),
            pairDevice: PairDeviceViaNFCUseCase(repository: repository),
            pendingStore: pendingStore,
            logout: logout,
            appState: appState
        )

        return NFCDependencies(coordinator: coordinator)
    }
}
