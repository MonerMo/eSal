//
//  AppPhase.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - App Phase

/// Top-level application state that drives root routing.
enum AppPhase: Equatable, Hashable {
    case unauthenticated
    case restoringSession
    case authenticated(UserSession)
}
