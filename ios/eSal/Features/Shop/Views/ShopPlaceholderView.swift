//
//  ShopPlaceholderView.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

struct ShopPlaceholderView: View {
    let title: String
    let systemImage: String
    let message: String

    var body: some View {
        EmptyState(icon: systemImage, title: title, message: message)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColors.background)
    }
}
