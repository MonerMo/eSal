//
//  NFCFlowCoordinator.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation
import Observation

// MARK: - NFC Flow Coordinator

@Observable
@MainActor
final class NFCFlowCoordinator {

    // MARK: - UI State

    private(set) var isProcessing = false
    private(set) var processingMessage = String(localized: "Processing NFC link...")
    var toast: ToastData?
    private(set) var retryableErrorMessage: String?

    // MARK: - Flow Handlers

    struct CustomerHandlers {
        /// Inserts/refreshes local lists and navigates to the claimed receipt.
        let handleClaimedReceipt: (Receipt) async -> Void
    }

    struct ShopHandlers {
        let showDevicesTab: () -> Void
        let refreshDevices: () async -> Void
    }

    private var customerHandlers: CustomerHandlers?
    private var shopHandlers: ShopHandlers?

    // MARK: - Dependencies

    private let claimReceipt: ClaimReceiptViaNFCUseCase
    private let pairDevice: PairDeviceViaNFCUseCase
    private let pendingStore: PendingNFCLinkStore
    private let logout: LogoutUseCase
    private let appState: AppStateMachine

    private var queuedURL: URL?
    private var activeIntent: NFCLinkIntent?
    private var processingKey: String?
    private var lastCompletedKey: String?
    private var lastCompletedAt: Date?
    private var pendingClaimedReceipt: Receipt?
    private var pendingDevicesNavigation = false
    private let duplicateWindow: TimeInterval = 3
    private let networkRetryAttempts = 3

    init(
        claimReceipt: ClaimReceiptViaNFCUseCase,
        pairDevice: PairDeviceViaNFCUseCase,
        pendingStore: PendingNFCLinkStore,
        logout: LogoutUseCase,
        appState: AppStateMachine
    ) {
        self.claimReceipt = claimReceipt
        self.pairDevice = pairDevice
        self.pendingStore = pendingStore
        self.logout = logout
        self.appState = appState
    }

    // MARK: - Handler Registration

    func registerCustomerHandlers(_ handlers: CustomerHandlers) {
        customerHandlers = handlers

        if let pendingClaimedReceipt {
            self.pendingClaimedReceipt = nil
            Task {
                await handlers.handleClaimedReceipt(pendingClaimedReceipt)
            }
        }
    }

    func registerShopHandlers(_ handlers: ShopHandlers) {
        shopHandlers = handlers

        if pendingDevicesNavigation {
            pendingDevicesNavigation = false
            handlers.showDevicesTab()
            Task {
                await handlers.refreshDevices()
            }
        }
    }

    // MARK: - App Lifecycle

    func handle(url: URL) async {
        #if DEBUG
        print("🔗 [NFC] Incoming URL: \(url.absoluteString)")
        #endif

        if case .restoringSession = appState.phase {
            queuedURL = url
            return
        }

        await process(url: url)
    }

    func onAppReady() async {
        if let queuedURL {
            self.queuedURL = nil
            await process(url: queuedURL)
            return
        }

        await resumePendingIfNeeded()
    }

    func resumePendingIfNeeded() async {
        guard case .authenticated = appState.phase else { return }
        guard let intent = pendingStore.peek() else { return }
        await process(intent: intent)
    }

    func retry() async {
        guard let intent = activeIntent else { return }
        retryableErrorMessage = nil
        await process(intent: intent)
    }

    func dismissRetryError() {
        retryableErrorMessage = nil
        activeIntent = nil
    }

    // MARK: - Processing

    private func process(url: URL) async {
        guard let intent = NFCLinkParser.parse(url) else {
            showToast(
                String(localized: "This link is not valid for eSal."),
                style: .error
            )
            return
        }

        await process(intent: intent)
    }

    private func process(intent: NFCLinkIntent) async {
        guard !shouldSkip(intent) else { return }

        activeIntent = intent
        retryableErrorMessage = nil

        guard case .authenticated(let session) = appState.phase else {
            pendingStore.store(intent)
            return
        }

        guard validateAccountType(session.accountType, for: intent.mode) else {
            pendingStore.clear()
            return
        }

        await execute(intent: intent, session: session)
    }

    private func execute(
        intent: NFCLinkIntent,
        session: UserSession
    ) async {
        guard !isProcessing else { return }

        isProcessing = true
        processingMessage = String(localized: "Processing NFC link...")
        processingKey = intent.deduplicationKey
        defer {
            isProcessing = false
            processingKey = nil
            processingMessage = String(localized: "Processing NFC link...")
        }

        do {
            switch intent.mode {
            case .claim:
                try await performClaim(intent, session: session)
            case .pair:
                try await performPair(intent)
            }

            pendingStore.clear()
            markCompleted(intent)
            activeIntent = nil
        } catch {
            handle(error, intent: intent)
        }
    }

    private func performClaim(_ intent: NFCLinkIntent, session: UserSession) async throws {
        guard session.accountType == .customer else {
            showWrongAccountTypeMessage(for: .claim)
            return
        }

        let result = try await withNetworkRetry {
            try await claimReceipt.execute(pairingId: intent.pairingId)
        }

        showToast(
            String(localized: "Receipt claimed successfully."),
            style: .success
        )

        if let customerHandlers {
            await customerHandlers.handleClaimedReceipt(result.receipt)
        } else {
            pendingClaimedReceipt = result.receipt
        }
    }

    private func performPair(_ intent: NFCLinkIntent) async throws {
        let result = try await withNetworkRetry {
            try await pairDevice.execute(pairingId: intent.pairingId)
        }

        let message = result.message?.trimmingCharacters(in: .whitespacesAndNewlines)
        showToast(
            message?.isEmpty == false
                ? message!
                : String(localized: "Device paired successfully."),
            style: .success
        )

        if let shopHandlers {
            shopHandlers.showDevicesTab()
            await shopHandlers.refreshDevices()
        } else {
            pendingDevicesNavigation = true
        }
    }

    // MARK: - Validation

    private func validateAccountType(_ accountType: AccountType, for mode: NFCLinkMode) -> Bool {
        switch (accountType, mode) {
        case (.shop, .pair), (.customer, .claim):
            return true
        case (.customer, .pair):
            showWrongAccountTypeMessage(for: .pair)
            return false
        case (.shop, .claim):
            showWrongAccountTypeMessage(for: .claim)
            return false
        }
    }

    private func showWrongAccountTypeMessage(for mode: NFCLinkMode) {
        let message: String
        switch mode {
        case .pair:
            message = String(localized: "Device pairing is only available for shop accounts.")
        case .claim:
            message = String(localized: "Receipt claiming is only available for customer accounts.")
        }
        showToast(message, style: .error)
    }

    // MARK: - Error Handling

    private func handle(
        _ error: Error,
        intent: NFCLinkIntent
    ) {
        if let apiError = error as? APIClientError {
            switch apiError {
            case .unauthorized:
                pendingStore.store(intent)
                logout.execute()
                showToast(
                    String(localized: "Your session has expired. Please sign in again."),
                    style: .error
                )
                return

            case .forbidden:
                pendingStore.clear()
                showToast(
                    String(localized: "You don't have permission to perform this action."),
                    style: .error
                )
                return

            case .conflict(let message):
                pendingStore.clear()
                showToast(
                    message.isEmpty
                        ? String(localized: "This device has already been paired.")
                        : message,
                    style: .error
                )
                return

            case .notFound(let message):
                pendingStore.clear()
                let fallback = mapNotFoundMessage(for: intent.mode)
                showToast(
                    message.isEmpty || message.hasPrefix("Request failed")
                        ? fallback
                        : message,
                    style: .error
                )
                return

            case .invalidResponse:
                pendingStore.clear()
                retryableErrorMessage = String(localized: "Something went wrong. Please try again later.")
                return

            case .server(let message):
                pendingStore.clear()
                if message.lowercased().contains("range") || message.lowercased().contains("invalid") {
                    showToast(message, style: .error)
                } else {
                    retryableErrorMessage = message.isEmpty
                        ? String(localized: "Something went wrong. Please try again later.")
                        : message
                }
                return
            }
        }

        if let authError = error as? AuthError, case .network = authError {
            pendingStore.store(intent)
            retryableErrorMessage = String(
                localized: "The connection was lost. The server may be waking up — please try again."
            )
            return
        }

        pendingStore.clear()
        retryableErrorMessage = error.localizedDescription
    }

    private func mapNotFoundMessage(for mode: NFCLinkMode) -> String {
        switch mode {
        case .pair:
            String(localized: "Device or pairing ID not found.")
        case .claim:
            String(localized: "No receipt is available for this pairing ID.")
        }
    }

    // MARK: - Network Retry

    /// Retries transient network failures (e.g. Render cold start / -1005).
    private func withNetworkRetry<T>(
        operation: () async throws -> T
    ) async throws -> T {
        var lastError: Error?

        for attempt in 1...networkRetryAttempts {
            do {
                return try await operation()
            } catch let error as AuthError where matchesNetworkFailure(error) {
                lastError = error
                guard attempt < networkRetryAttempts else { break }

                processingMessage = String(
                    localized: "Server is waking up… retrying (\(attempt + 1)/\(networkRetryAttempts))"
                )
                try? await Task.sleep(for: .seconds(2 * attempt))
            } catch {
                throw error
            }
        }

        throw lastError ?? AuthError.network
    }

    private func matchesNetworkFailure(_ error: AuthError) -> Bool {
        if case .network = error { return true }
        return false
    }

    // MARK: - Helpers

    private func shouldSkip(_ intent: NFCLinkIntent) -> Bool {
        let key = intent.deduplicationKey

        if isProcessing, processingKey == key {
            return true
        }

        if let lastCompletedKey,
           lastCompletedKey == key,
           let lastCompletedAt,
           Date().timeIntervalSince(lastCompletedAt) < duplicateWindow {
            return true
        }

        return false
    }

    private func markCompleted(_ intent: NFCLinkIntent) {
        lastCompletedKey = intent.deduplicationKey
        lastCompletedAt = .now
    }

    private func showToast(_ message: String, style: ToastStyle) {
        toast = ToastData(message: message, style: style)
    }
}
