//
//  RegistrationFlowStep.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - Registration Flow Step

enum RegistrationFlowStep: Equatable, Hashable {
    case accountType
    case details
    case success(email: String)
}

// MARK: - Flow Navigation Direction

enum FlowNavigationDirection {
    case forward
    case backward
}
