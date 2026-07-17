//
//  InsightsViewModel.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation
import Observation

// MARK: - Insights View Model

@Observable
@MainActor
final class InsightsViewModel {

    private(set) var isLoading = false
    private(set) var hasLoaded = false
    private(set) var selectedRange: InsightsRange = .thisMonth
    private(set) var totalSpending: Decimal = 0
    private(set) var categories: [InsightsCategorySpending] = []
    private(set) var errorMessage: String?

    var insights: Insights? {
        guard hasLoaded, errorMessage == nil else { return nil }
        return Insights(
            range: selectedRange,
            totalSpending: totalSpending,
            categories: categories
        )
    }

    var formattedTotalSpending: String {
        Receipt.formatMoney(totalSpending)
    }

    var showsEmptyCategories: Bool {
        hasLoaded && errorMessage == nil && categories.isEmpty
    }

    var showsFullScreenError: Bool {
        errorMessage != nil && !hasLoaded
    }

    var showsFullScreenLoading: Bool {
        isLoading && !hasLoaded
    }

    var showsInlineLoading: Bool {
        isLoading && hasLoaded
    }

    var showsInlineError: Bool {
        errorMessage != nil && hasLoaded && !isLoading
    }

    private let getInsights: GetInsightsUseCase
    private let logout: LogoutUseCase
    private var fetchGeneration = 0

    init(getInsights: GetInsightsUseCase, logout: LogoutUseCase) {
        self.getInsights = getInsights
        self.logout = logout
    }

    func load() async {
        await loadInsights(range: selectedRange)
    }

    func refresh() async {
        await loadInsights(range: selectedRange)
    }

    func loadInsights(range: InsightsRange) async {
        selectedRange = range
        await fetchInsights()
    }

    func selectRange(_ range: InsightsRange) async {
        guard range != selectedRange else { return }
        await loadInsights(range: range)
    }

    private func fetchInsights() async {
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
            let insights = try await getInsights.execute(range: selectedRange)
            guard generation == fetchGeneration else { return }

            apply(insights)
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

    private func apply(_ insights: Insights) {
        selectedRange = insights.range
        totalSpending = insights.totalSpending
        categories = insights.categories
    }

    private func handle(_ error: Error) {
        if let apiError = error as? APIClientError {
            switch apiError {
            case .unauthorized:
                logout.execute()
                return
            case .forbidden:
                errorMessage = error.localizedDescription
            case .server(let message):
                errorMessage = mapServerMessage(message)
            case .conflict, .invalidResponse, .notFound:
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

    private func mapServerMessage(_ message: String) -> String {
        let normalized = message.lowercased()

        if normalized.contains("range") {
            return String(localized: "Invalid time range. Please try again.")
        }

        return message.isEmpty
            ? String(localized: "Something went wrong. Please try again later.")
            : message
    }
}

typealias ShopInsightsViewModel = InsightsViewModel
