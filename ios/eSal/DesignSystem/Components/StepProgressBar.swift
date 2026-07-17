//
//  StepProgressBar.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

// MARK: - Step Progress Bar

/// Reusable horizontal progress indicator for multi-step flows.
struct StepProgressBar: View {
    let progress: Double

    private var clampedProgress: Double {
        min(1, max(0, progress))
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(AppColors.disabled.opacity(0.35))
                    .frame(height: 4)

                Capsule()
                    .fill(AppColors.success)
                    .frame(width: geometry.size.width * clampedProgress, height: 4)
            }
        }
        .frame(height: 4)
        .animation(.easeInOut(duration: Theme.Animation.standard), value: clampedProgress)
    }
}
