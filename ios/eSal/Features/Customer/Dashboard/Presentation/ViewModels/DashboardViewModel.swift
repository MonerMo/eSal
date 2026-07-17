//
//  DashboardViewModel.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation
import Observation

// MARK: - Dashboard View Model

@Observable
@MainActor
final class DashboardViewModel {

    private(set) var isLoading = false
    private(set) var hasLoaded = false
    private(set) var firstName = ""
    private(set) var totalSpendingThisMonth: Decimal = 0
    private(set) var nearestWarranty: DashboardWarranty?
    private(set) var recentReceipts: [Receipt] = []
    private(set) var smartOffers: [SmartOffer] = []
    private(set) var errorMessage: String?

    var formattedMonthlySpending: String {
        Receipt.formatMoney(totalSpendingThisMonth)
    }

    var showsSmartOffers: Bool {
        !smartOffers.isEmpty
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

    private let getDashboard: GetDashboardUseCase
    private let logout: LogoutUseCase

    init(getDashboard: GetDashboardUseCase, logout: LogoutUseCase) {
        self.getDashboard = getDashboard
        self.logout = logout
    }

    func load() async {
        await fetchDashboard(force: false)
    }

    func refresh() async {
        await fetchDashboard(force: true)
    }

    /// Keeps a newly claimed receipt visible on the dashboard while the API catches up.
    func upsertRecentReceipt(_ receipt: Receipt) {
        recentReceipts.removeAll { $0.id == receipt.id }
        recentReceipts.insert(receipt, at: 0)
        if recentReceipts.count > 10 {
            recentReceipts = Array(recentReceipts.prefix(10))
        }
        errorMessage = nil
        hasLoaded = true
    }

    /// Refreshes dashboard data, then re-applies `receipt` so a lagging claim is not lost.
    func refreshPreservingRecentReceipt(_ receipt: Receipt) async {
        await refresh()
        upsertRecentReceipt(receipt)
    }

    private func fetchDashboard(force: Bool) async {
        guard force || !isLoading else { return }

        isLoading = true
        if !hasLoaded {
            errorMessage = nil
        }

        defer {
            isLoading = false
            hasLoaded = true
        }

        do {
            let dashboard = try await getDashboard.execute()
            apply(dashboard)
            errorMessage = nil
        } catch {
            handle(error)
        }
    }

    private func apply(_ dashboard: Dashboard) {
        firstName = dashboard.firstName
        totalSpendingThisMonth = dashboard.totalSpendingThisMonth
        nearestWarranty = dashboard.nearestWarranty
        recentReceipts = dashboard.recentReceipts
        smartOffers = dashboard.smartOffers
    }

    private func handle(_ error: Error) {
        if let apiError = error as? APIClientError {
            switch apiError {
            case .unauthorized:
                logout.execute()
                return
            case .notFound:
                errorMessage = String(localized: "We couldn't find your account. Please sign in again.")
            case .forbidden, .conflict, .invalidResponse, .server:
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
