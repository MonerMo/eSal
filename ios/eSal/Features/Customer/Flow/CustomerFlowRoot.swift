//
//  CustomerFlowRoot.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

// MARK: - Customer Flow Root

struct CustomerFlowRoot: View {

    let dependencies: CustomerFlowDependencies

    var body: some View {
        CustomerTabView(dependencies: dependencies)
    }
}
