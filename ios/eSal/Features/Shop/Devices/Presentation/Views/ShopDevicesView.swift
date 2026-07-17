//
//  ShopDevicesView.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

struct ShopDevicesView: View {

    @Bindable var viewModel: ShopDevicesViewModel

    var body: some View {
        Group {
            if viewModel.showsFullScreenLoading {
                loadingContent
            } else if viewModel.showsFullScreenError, let message = viewModel.errorMessage {
                ErrorView(message: message, isRetryable: true) {
                    Task { await viewModel.load() }
                }
            } else if viewModel.showsEmptyState {
                EmptyState(
                    icon: "qrcode.viewfinder",
                    title: String(localized: "No Devices Yet"),
                    message: String(localized: "Pair QR and NFC devices to your store. They will appear here once connected.")
                )
            } else {
                deviceList
            }
        }
        .background(AppColors.background)
        .appLargeNavigationTitle(String(localized: "Devices"))
        .task {
            if !viewModel.hasLoaded && !viewModel.isLoading {
                await viewModel.load()
            }
        }
    }

    private var deviceList: some View {
        ScrollView {
            LazyVStack(spacing: Theme.Spacing.medium) {
                ForEach(viewModel.devices) { device in
                    ShopDeviceCardView(device: device)
                }
            }
            .padding(.horizontal, Theme.Spacing.large)
            .padding(.vertical, Theme.Spacing.large)
        }
        .refreshable {
            await viewModel.refresh()
        }
    }

    private var loadingContent: some View {
        ScrollView {
            LazyVStack(spacing: Theme.Spacing.medium) {
                ForEach(0..<4, id: \.self) { _ in
                    ReceiptCardSkeletonView()
                }
            }
            .padding(.horizontal, Theme.Spacing.large)
            .padding(.vertical, Theme.Spacing.large)
        }
    }
}

#Preview {
    NavigationStack {
        ShopDevicesView(
            viewModel: ShopDevicesViewModel(
                getDevices: GetShopDevicesUseCase(
                    repository: ShopDeviceRepository(
                        remoteDataSource: ShopDeviceRemoteDataSource(
                            client: APIClient(
                                baseURL: APIConfig.baseURL,
                                tokenProvider: { nil }
                            )
                        )
                    )
                )
            )
        )
    }
}
