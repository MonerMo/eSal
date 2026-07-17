//
//  AddPassView.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import PassKit
import SwiftUI
import UIKit

// MARK: - Wallet Pass Button

/// Apple's recommended SwiftUI control for adding a pass to Wallet (WWDC22).
/// The official button stays visible; the pass is fetched only when the user taps it.
/// See: https://developer.apple.com/documentation/passkit/addpasstowalletbutton
struct WalletPassButton: View {

    let viewModel: ProfileViewModel

    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            if !PKAddPassesViewController.canAddPasses() {
                walletUnavailableView
            } else if viewModel.isPassInWallet {
                passInWalletView
            } else {
                addPassButton
            }
        }
        .onAppear {
            viewModel.syncWalletPresence()
        }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            viewModel.syncWalletPresence()
        }
        .onReceive(NotificationCenter.default.publisher(for: .PKPassLibraryDidChange)) { _ in
            viewModel.syncWalletPresence()
        }
    }

    private var addPassButton: some View {
        ZStack {
            AddPassToWalletButton {
                Task { await addPassToWallet() }
            }
            .addPassToWalletButtonStyle(.blackOutline)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .allowsHitTesting(!viewModel.isLoadingWalletPass)
            .opacity(viewModel.isLoadingWalletPass ? 0.55 : 1)

            if viewModel.isLoadingWalletPass {
                ProgressView()
                    .tint(AppColors.onPrimary)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 50)
    }

    private var passInWalletView: some View {
        Label(
            String(localized: "Added to Apple Wallet"),
            systemImage: "checkmark.circle.fill"
        )
        .font(AppTypography.body)
        .foregroundStyle(AppColors.secondaryText)
        .frame(maxWidth: .infinity)
        .frame(height: 50)
    }

    private var walletUnavailableView: some View {
        Text(String(localized: "Apple Wallet is not available on this device."))
            .font(AppTypography.caption)
            .foregroundStyle(AppColors.secondaryText)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
    }

    @MainActor
    private func addPassToWallet() async {
        guard !viewModel.isLoadingWalletPass else { return }

        do {
            let pass = try await viewModel.fetchWalletPassForAdding()
            WalletPassAddPresenter.present(pass: pass) { added in
                viewModel.handleWalletPassAdded(added)
            }
        } catch is CancellationError {
            return
        } catch {
            viewModel.handleWalletPassFetchError(error)
        }
    }
}

// MARK: - Wallet Pass Add Presenter

@MainActor
private enum WalletPassAddPresenter {
    private final class Delegate: NSObject, PKAddPassesViewControllerDelegate {
        private let pass: PKPass
        private let onFinish: (Bool) -> Void

        init(pass: PKPass, onFinish: @escaping (Bool) -> Void) {
            self.pass = pass
            self.onFinish = onFinish
        }

        func addPassesViewControllerDidFinish(_ controller: PKAddPassesViewController) {
            controller.dismiss(animated: true) { [pass, onFinish] in
                onFinish(PKPassLibrary().containsPass(pass))
            }
        }
    }

    private static var activeDelegate: Delegate?

    static func present(pass: PKPass, onFinish: @escaping (Bool) -> Void) {
        guard
            PKAddPassesViewController.canAddPasses(),
            let addPassViewController = PKAddPassesViewController(pass: pass),
            let presenter = topViewController()
        else {
            onFinish(false)
            return
        }

        let delegate = Delegate(pass: pass) { added in
            activeDelegate = nil
            onFinish(added)
        }
        activeDelegate = delegate
        addPassViewController.delegate = delegate
        presenter.present(addPassViewController, animated: true)
    }

    private static func topViewController() -> UIViewController? {
        guard
            let windowScene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive }),
            let root = windowScene.windows.first(where: \.isKeyWindow)?.rootViewController
        else {
            return nil
        }

        return topMostViewController(from: root)
    }

    private static func topMostViewController(from viewController: UIViewController) -> UIViewController {
        if let presented = viewController.presentedViewController {
            return topMostViewController(from: presented)
        }
        if let navigation = viewController as? UINavigationController,
           let visible = navigation.visibleViewController {
            return topMostViewController(from: visible)
        }
        if let tabBar = viewController as? UITabBarController,
           let selected = tabBar.selectedViewController {
            return topMostViewController(from: selected)
        }
        return viewController
    }
}

private extension Notification.Name {
    static let PKPassLibraryDidChange = Notification.Name("PKPassLibraryDidChangeNotification")
}
