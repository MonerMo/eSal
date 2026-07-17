//
//  DashboardRepositoryProtocol.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - Dashboard Repository

protocol DashboardRepositoryProtocol: Sendable {
    func fetchDashboard() async throws -> Dashboard
}
