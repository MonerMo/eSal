//
//  ShopDashboardRepositoryProtocol.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

protocol ShopDashboardRepositoryProtocol: Sendable {
    func getDashboard() async throws -> ShopDashboard
}
