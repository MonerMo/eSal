//
//  ShopFlowRoot.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

struct ShopFlowRoot: View {

    let dependencies: ShopFlowDependencies

    var body: some View {
        ShopTabView(dependencies: dependencies)
    }
}
