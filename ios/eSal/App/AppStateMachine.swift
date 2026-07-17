//
//  AppStateMachine.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation
import Observation

// MARK: - App State Machine

/// Single source of truth for which root flow the app displays.
@Observable
@MainActor
final class AppStateMachine {

    private(set) var phase: AppPhase

    init(phase: AppPhase = .unauthenticated) {
        self.phase = phase
    }

    func setPhase(_ phase: AppPhase) {
        self.phase = phase
    }
}
