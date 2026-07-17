//
//  ShopDevicesViewModel.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation
import Observation

@Observable
@MainActor
final class ShopDevicesViewModel {

    private(set) var devices: [ShopDevice] = []
    private(set) var isLoading = false
    private(set) var hasLoaded = false
    private(set) var errorMessage: String?

    var showsEmptyState: Bool {
        hasLoaded && errorMessage == nil && devices.isEmpty
    }

    var showsFullScreenError: Bool {
        errorMessage != nil && !hasLoaded
    }

    var showsFullScreenLoading: Bool {
        isLoading && !hasLoaded
    }

    private let getDevices: GetShopDevicesUseCase
    private var fetchGeneration = 0

    init(getDevices: GetShopDevicesUseCase) {
        self.getDevices = getDevices
    }

    func load() async {
        await fetchDevices()
    }

    func refresh() async {
        await fetchDevices()
    }

    private func fetchDevices() async {
        fetchGeneration += 1
        let generation = fetchGeneration

        isLoading = true
        if !hasLoaded {
            errorMessage = nil
        }

        defer {
            if generation == fetchGeneration {
                isLoading = false
            }
        }

        do {
            let result = try await getDevices.execute()
            guard generation == fetchGeneration else { return }

            devices = result
            hasLoaded = true
            errorMessage = nil
        } catch is CancellationError {
            return
        } catch let error as URLError where error.code == .cancelled {
            return
        } catch {
            guard generation == fetchGeneration else { return }
            if !hasLoaded {
                devices = []
            }
            errorMessage = error.localizedDescription
        }
    }
}
