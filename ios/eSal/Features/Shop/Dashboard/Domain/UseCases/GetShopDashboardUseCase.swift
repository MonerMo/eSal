//
//  GetShopDashboardUseCase.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

struct GetShopDashboardUseCase: Sendable {
    private let repository: ShopDashboardRepositoryProtocol

    init(repository: ShopDashboardRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> ShopDashboard {
        try await repository.getDashboard()
    }
}
