//
//  CustomerFlowFactory.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

// MARK: - Customer Flow Factory

@MainActor
struct CustomerFlowFactory: FlowFactory {

    private let dependencies: CustomerFlowDependencies

    init(dependencies: CustomerFlowDependencies) {
        self.dependencies = dependencies
    }

    func makeRoot(session: UserSession) -> AnyView {
        AnyView(CustomerFlowRoot(dependencies: dependencies))
    }
}
