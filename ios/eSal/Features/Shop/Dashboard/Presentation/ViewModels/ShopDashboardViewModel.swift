//
//  ShopDashboardViewModel.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation
import Observation

@Observable
@MainActor
final class ShopDashboardViewModel {

    private(set) var dashboard: ShopDashboard?
    private(set) var isLoading = false
    private(set) var hasLoaded = false
    private(set) var errorMessage: String?

    var formattedRevenue: String {
        Receipt.formatMoney(dashboard?.totalRevenueThisMonth ?? 0)
    }

    var formattedReceiptCount: String {
        let count = dashboard?.receiptCountThisMonth ?? 0
        return String(localized: "\(count) receipts this month")
    }

    var navigationTitle: String {
        guard let storeName = dashboard?.storeName, !storeName.isEmpty else {
            return String(localized: "Hello")
        }
        return String(localized: "Hello, \(storeName)")
    }

    var recentReceipts: [Receipt] {
        dashboard?.recentReceipts ?? []
    }

    var showsEmptyReceipts: Bool {
        hasLoaded && errorMessage == nil && recentReceipts.isEmpty
    }

    var showsFullScreenError: Bool {
        errorMessage != nil && !hasLoaded
    }

    var showsFullScreenLoading: Bool {
        isLoading && !hasLoaded
    }

    private let getDashboard: GetShopDashboardUseCase
    private let logout: LogoutUseCase
    private var fetchGeneration = 0

    init(getDashboard: GetShopDashboardUseCase, logout: LogoutUseCase) {
        self.getDashboard = getDashboard
        self.logout = logout
    }

    func loadDashboard() async {
        await fetchDashboard()
    }

    func refresh() async {
        await fetchDashboard()
    }

    private func fetchDashboard() async {
        fetchGeneration += 1
        let generation = fetchGeneration

        isLoading = true
        if !hasLoaded {
            errorMessage = nil
        }

        defer {
            if generation == fetchGeneration {
                isLoading = false
                hasLoaded = true
            }
        }

        do {
            let dashboard = try await getDashboard.execute()
            guard generation == fetchGeneration else { return }

            self.dashboard = dashboard
            errorMessage = nil
        } catch is CancellationError {
            return
        } catch let error as URLError where error.code == .cancelled {
            return
        } catch {
            guard generation == fetchGeneration else { return }
            handle(error)
        }
    }

    private func handle(_ error: Error) {
        if let apiError = error as? APIClientError {
            switch apiError {
            case .unauthorized:
                logout.execute()
                return
            case .notFound:
                errorMessage = String(localized: "We couldn't find your account. Please sign in again.")
            case .forbidden:
                errorMessage = error.localizedDescription
            case .conflict, .invalidResponse, .server:
                errorMessage = String(localized: "Something went wrong. Please try again later.")
            }
            return
        }

        if let authError = error as? AuthError {
            switch authError {
            case .network:
                errorMessage = String(localized: "No internet connection. Please try again.")
            default:
                errorMessage = String(localized: "Something went wrong. Please try again later.")
            }
            return
        }

        errorMessage = error.localizedDescription
    }
}
