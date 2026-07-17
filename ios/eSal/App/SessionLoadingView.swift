//
//  SessionLoadingView.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

// MARK: - Session Loading View

struct SessionLoadingView: View {
    var body: some View {
        LoadingView(String(localized: "Restoring your session…"))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColors.background)
    }
}
