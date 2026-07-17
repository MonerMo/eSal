//
//  eSalApp.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

// MARK: - App Entry

@main
struct eSalApp: App {

    @State private var container = AppContainer()

    init() {
        AppTabBarAppearance.configure()
    }

    var body: some Scene {
        WindowGroup {
            @Bindable var appState = container.appState
            @Bindable var nfcCoordinator = container.nfc.coordinator

            AppRootView(
                appState: appState,
                nfcCoordinator: nfcCoordinator,
                container: container
            )
            .onOpenURL { url in
                Task { await nfcCoordinator.handle(url: url) }
            }
            .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { activity in
                guard let url = activity.webpageURL else { return }
                Task { await nfcCoordinator.handle(url: url) }
            }
            .task {
                await container.bootstrapIfNeeded()
                await nfcCoordinator.onAppReady()
            }
        }
    }
}
