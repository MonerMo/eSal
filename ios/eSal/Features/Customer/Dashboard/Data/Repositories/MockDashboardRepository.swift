//
//  MockDashboardRepository.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - Mock Dashboard Repository

struct MockDashboardRepository: DashboardRepositoryProtocol {

    private let simulatedDelay: Duration
    private let dashboard: Dashboard

    init(
        dashboard: Dashboard = .sample,
        simulatedDelay: Duration = .milliseconds(600)
    ) {
        self.dashboard = dashboard
        self.simulatedDelay = simulatedDelay
    }

    func fetchDashboard() async throws -> Dashboard {
        try await Task.sleep(for: simulatedDelay)
        return dashboard
    }
}
