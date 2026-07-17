//
//  ShopFlowFactory.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

@MainActor
struct ShopFlowFactory: FlowFactory {

    private let dependencies: ShopFlowDependencies

    init(dependencies: ShopFlowDependencies) {
        self.dependencies = dependencies
    }

    func makeRoot(session: UserSession) -> AnyView {
        AnyView(ShopFlowRoot(dependencies: dependencies))
    }
}
