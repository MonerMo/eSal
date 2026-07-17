//
//  ProfileViewModel.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation
import Observation
import PassKit

// MARK: - Profile View Model

@Observable
@MainActor
final class ProfileViewModel {

    private(set) var isLoadingWalletPass = false
    private(set) var walletPass: PKPass?
    private(set) var walletLibraryRevision = 0
    private(set) var errorMessage: String?

    private let walletService: WalletServiceProtocol
    private let passReferenceStore: WalletPassReferenceStore
    private let passLibrary = PKPassLibrary()
    private var fetchGeneration = 0

    init(
        walletService: WalletServiceProtocol,
        passReferenceStore: WalletPassReferenceStore = WalletPassReferenceStore()
    ) {
        self.walletService = walletService
        self.passReferenceStore = passReferenceStore
    }

    var isPassInWallet: Bool {
        resolvePassInLibrary() != nil
    }

    func canAddPass(_ pass: PKPass) -> Bool {
        _ = walletLibraryRevision
        guard PKAddPassesViewController.canAddPasses() else { return false }
        return !passLibrary.containsPass(pass)
    }

    func syncWalletPresence() {
        refreshWalletPassLibraryState()
    }

    func fetchWalletPassForAdding() async throws -> PKPass {
        if let cachedPass = walletPass, !passLibrary.containsPass(cachedPass) {
            return cachedPass
        }

        fetchGeneration += 1
        let generation = fetchGeneration

        isLoadingWalletPass = true
        errorMessage = nil

        defer {
            if generation == fetchGeneration {
                isLoadingWalletPass = false
            }
        }

        do {
            let passData = try await walletService.fetchWalletPass()
            guard generation == fetchGeneration else { throw CancellationError() }

            let pass = try PKPass(data: passData)
            walletPass = pass
            passReferenceStore.save(
                WalletPassReference(
                    passTypeIdentifier: pass.passTypeIdentifier,
                    serialNumber: pass.serialNumber
                )
            )
            refreshWalletPassLibraryState()
            return pass
        } catch is CancellationError {
            throw CancellationError()
        } catch let error as WalletServiceError {
            handleFetchFailure(error, generation: generation)
            throw error
        } catch {
            handleFetchFailure(error, generation: generation)
            throw error
        }
    }

    func handleWalletPassAdded(_ added: Bool) {
        guard added else { return }
        refreshWalletPassLibraryState()
    }

    func handleWalletPassFetchError(_ error: Error) {
        guard !(error is CancellationError) else { return }
        errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
    }

    func refreshWalletPassLibraryState() {
        walletLibraryRevision &+= 1
    }

    func clearError() {
        errorMessage = nil
    }

    private func resolvePassInLibrary() -> PKPass? {
        _ = walletLibraryRevision

        if let walletPass, passLibrary.containsPass(walletPass) {
            return walletPass
        }

        guard let reference = passReferenceStore.load() else { return nil }

        guard
            let storedPass = passLibrary.pass(
                withPassTypeIdentifier: reference.passTypeIdentifier,
                serialNumber: reference.serialNumber
            ),
            passLibrary.containsPass(storedPass)
        else {
            return nil
        }

        walletPass = storedPass
        return storedPass
    }

    private func handleFetchFailure(_ error: Error, generation: Int) {
        guard generation == fetchGeneration else { return }
        errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        walletPass = nil
        refreshWalletPassLibraryState()
    }
}
