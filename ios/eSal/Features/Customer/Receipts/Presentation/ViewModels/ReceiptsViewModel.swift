//
//  ReceiptsViewModel.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation
import Observation

// MARK: - Receipts View Model

@Observable
@MainActor
final class ReceiptsViewModel {

    // MARK: - Filter

    var filter = ReceiptFilter()

    // MARK: - State

    private(set) var receipts: [Receipt] = []
    private(set) var isLoading = false
    private(set) var isLoadingMore = false
    private(set) var errorMessage: String?
    private(set) var pagination = ReceiptPagination(page: 1, pageSize: 20, total: 0, totalPages: 0)

    var showsEmptyState: Bool {
        !isLoading && errorMessage == nil && receipts.isEmpty
    }

    // MARK: - Dependencies

    private let getReceipts: GetReceiptsUseCase
    private var searchTask: Task<Void, Never>?
    private var fetchGeneration = 0

    // MARK: - Initialization

    init(getReceipts: GetReceiptsUseCase) {
        self.getReceipts = getReceipts
    }

    // MARK: - Loading

    func load() async {
        searchTask?.cancel()
        filter.resetPage()
        await fetch(resetList: true)
    }

    func refresh() async {
        searchTask?.cancel()
        filter.resetPage()
        await fetch(resetList: true)
    }

    /// Ensures a claimed receipt appears immediately, even if the list API is briefly stale.
    func upsert(_ receipt: Receipt) {
        errorMessage = nil

        if let index = receipts.firstIndex(where: { $0.id == receipt.id }) {
            receipts.remove(at: index)
        } else if pagination.total >= 0 {
            pagination = ReceiptPagination(
                page: pagination.page,
                pageSize: pagination.pageSize,
                total: pagination.total + 1,
                totalPages: max(pagination.totalPages, 1)
            )
        }

        receipts.insert(receipt, at: 0)
    }

    /// Refreshes from the server, then re-applies `receipt` so a lagging claim is not lost.
    func refreshPreserving(_ receipt: Receipt) async {
        await refresh()
        upsert(receipt)
    }

    func loadMoreIfNeeded(currentReceipt: Receipt) async {
        guard receipts.last?.id == currentReceipt.id else { return }
        guard !isLoading, !isLoadingMore, pagination.hasMorePages else { return }

        filter.page = pagination.page + 1
        await fetch(resetList: false)
    }

    // MARK: - Filters

    func updateSearch(_ text: String) {
        filter.search = text
        scheduleSearchReload()
    }

    func selectRange(_ range: ReceiptTimeFilter) {
        guard filter.range != range else { return }
        searchTask?.cancel()
        filter.range = range
        filter.resetPage()
        Task { await fetch(resetList: true) }
    }

    func selectCategory(_ category: ReceiptCategoryFilter?) {
        guard filter.category != category else { return }
        searchTask?.cancel()
        filter.category = category
        filter.resetPage()
        Task { await fetch(resetList: true) }
    }

    func clearFilters() {
        searchTask?.cancel()
        filter = ReceiptFilter()
        Task { await fetch(resetList: true) }
    }

    // MARK: - Private

    private func fetch(resetList: Bool) async {
        fetchGeneration += 1
        let generation = fetchGeneration

        if resetList {
            isLoading = true
            errorMessage = nil
        } else {
            isLoadingMore = true
        }

        defer {
            if generation == fetchGeneration {
                isLoading = false
                isLoadingMore = false
            }
        }

        do {
            let result = try await getReceipts.execute(filter: filter)
            guard generation == fetchGeneration else { return }

            if resetList {
                receipts = result.receipts
            } else {
                receipts.append(contentsOf: result.receipts)
            }

            pagination = result.pagination
            filter.page = result.pagination.page
        } catch is CancellationError {
            return
        } catch let error as URLError where error.code == .cancelled {
            return
        } catch {
            guard generation == fetchGeneration else { return }
            if resetList {
                receipts = []
                errorMessage = error.localizedDescription
            }
        }
    }

    private func scheduleSearchReload() {
        searchTask?.cancel()
        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(400))
            guard !Task.isCancelled else { return }
            filter.resetPage()
            await fetch(resetList: true)
        }
    }
}
