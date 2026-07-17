//
//  ReceiptsView.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

// MARK: - Receipts View

struct ReceiptsView: View {

    @Bindable var viewModel: ReceiptsViewModel

    let configuration: ReceiptsViewConfiguration
    let onReceiptSelected: (Receipt) -> Void

    init(
        viewModel: ReceiptsViewModel,
        configuration: ReceiptsViewConfiguration = .customer,
        onReceiptSelected: @escaping (Receipt) -> Void
    ) {
        self.viewModel = viewModel
        self.configuration = configuration
        self.onReceiptSelected = onReceiptSelected
    }

    var body: some View {
        VStack(spacing: 0) {
            filterSection
                .padding(.horizontal, Theme.Spacing.large)
                .padding(.bottom, Theme.Spacing.small)

            content
        }
        .background(AppColors.background)
        .searchable(
            text: searchBinding,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: Text(configuration.searchPrompt)
        )
        .appSearchNavigationBarStyle()
        .appLargeNavigationTitle(String(localized: "Receipts"))
        .task {
            if viewModel.receipts.isEmpty && !viewModel.isLoading {
                await viewModel.load()
            }
        }
    }

    // MARK: - Search Binding

    private var searchBinding: Binding<String> {
        Binding(
            get: { viewModel.filter.search },
            set: { viewModel.updateSearch($0) }
        )
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.receipts.isEmpty {
            skeletonContent
        } else if let errorMessage = viewModel.errorMessage, viewModel.receipts.isEmpty {
            ErrorView(message: errorMessage, isRetryable: true) {
                Task { await viewModel.load() }
            }
        } else if viewModel.showsEmptyState {
            emptyState
        } else {
            receiptList
        }
    }

    private var receiptList: some View {
        ScrollView {
            LazyVStack(spacing: Theme.Spacing.medium) {
                if viewModel.filter.hasActiveFilters {
                    resultsSummary
                }

                ForEach(Array(viewModel.receipts.enumerated()), id: \.element.id) { index, receipt in
                    Button {
                        selectReceipt(receipt)
                    } label: {
                        ReceiptCardView(receipt: receipt, audience: configuration.cardAudience)
                    }
                    .buttonStyle(.plain)
                    .appListAppearAnimation(index: min(index, 8))
                    .onAppear {
                        Task { await viewModel.loadMoreIfNeeded(currentReceipt: receipt) }
                    }
                }

                if viewModel.isLoadingMore {
                    ReceiptCardSkeletonView()
                        .padding(.vertical, Theme.Spacing.xxSmall)
                }
            }
            .padding(.horizontal, Theme.Spacing.large)
            .padding(.bottom, Theme.Spacing.large)
            .animation(.easeOut(duration: Theme.Animation.standard), value: viewModel.receipts.count)
        }
        .refreshable {
            await viewModel.refresh()
        }
    }

    private var resultsSummary: some View {
        HStack {
            Text(resultsSummaryText)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.secondaryText)

            Spacer()

            Button(String(localized: "Clear Filters")) {
                viewModel.clearFilters()
            }
            .font(AppTypography.caption)
            .foregroundStyle(AppColors.p100)
        }
        .padding(.bottom, Theme.Spacing.xxSmall)
    }

    private var resultsSummaryText: String {
        let total = viewModel.pagination.total
        if total == 1 {
            return String(localized: "1 receipt found")
        }
        return String(localized: "\(total) receipts found")
    }

    private var skeletonContent: some View {
        ScrollView {
            LazyVStack(spacing: Theme.Spacing.medium) {
                ForEach(0..<6, id: \.self) { _ in
                    ReceiptCardSkeletonView()
                }
            }
            .padding(.horizontal, Theme.Spacing.large)
            .padding(.bottom, Theme.Spacing.large)
        }
    }

    // MARK: - Filters

    private var filterSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            HStack {
                Text(String(localized: "Filters"))
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.secondaryText)

                Spacer()

                if viewModel.filter.hasActiveFilters {
                    Button(String(localized: "Clear")) {
                        viewModel.clearFilters()
                    }
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.p100)
                }
            }

            timeFilterRow
            categoryFilterRow
        }
    }

    private var timeFilterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Theme.Spacing.xSmall) {
                ForEach(ReceiptTimeFilter.allCases) { range in
                    ReceiptFilterChip(
                        title: range.label,
                        isSelected: viewModel.filter.range == range
                    ) {
                        viewModel.selectRange(range)
                    }
                }
            }
            .padding(.vertical, Theme.Spacing.xxSmall)
        }
    }

    private var categoryFilterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Theme.Spacing.xSmall) {
                ForEach(configuration.categoryFilters) { category in
                    ReceiptFilterChip(
                        title: category.label,
                        isSelected: viewModel.filter.category == category
                    ) {
                        let isSelected = viewModel.filter.category == category
                        viewModel.selectCategory(isSelected ? nil : category)
                    }
                }
            }
            .padding(.vertical, Theme.Spacing.xxSmall)
        }
    }

    // MARK: - Empty State

    @ViewBuilder
    private var emptyState: some View {
        if viewModel.filter.hasActiveFilters {
            EmptyState(
                icon: AppIcons.receipts,
                title: String(localized: "No Receipts Found"),
                message: configuration.emptyFilteredMessage
            )
        } else {
            EmptyState(
                icon: AppIcons.receipts,
                title: configuration.emptyTitle,
                message: configuration.emptyMessage
            )
        }
    }

    private func selectReceipt(_ receipt: Receipt) {
        onReceiptSelected(receipt)
    }
}

#Preview {
    @Previewable @State var router = CustomerRouter()

    NavigationStack {
        ReceiptsView(
            viewModel: ReceiptsViewModel(
                getReceipts: GetReceiptsUseCase(repository: MockReceiptRepository())
            ),
            onReceiptSelected: { receipt in
                router.showReceiptDetails(receipt)
            }
        )
        .navigationTitle("Receipts")
    }
}
