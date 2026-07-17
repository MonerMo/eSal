//
//  AppCardStyle.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

// MARK: - App Card Style

struct AppCardStyle: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    var padding: CGFloat = Theme.Spacing.medium
    var cornerRadius: CGFloat = Theme.Radius.large
    var shadowOpacity: Double = 0.07

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(AppColors.border.opacity(colorScheme == .dark ? 0.35 : 0.18), lineWidth: 0.5)
            }
            .shadow(
                color: AppColors.cardShadow(for: colorScheme, opacity: shadowOpacity),
                radius: Theme.Shadow.cardRadius,
                y: Theme.Shadow.cardYOffset
            )
    }
}

extension View {
    func appCardStyle(
        padding: CGFloat = Theme.Spacing.medium,
        cornerRadius: CGFloat = Theme.Radius.large,
        shadowOpacity: Double = 0.07
    ) -> some View {
        modifier(
            AppCardStyle(
                padding: padding,
                cornerRadius: cornerRadius,
                shadowOpacity: shadowOpacity
            )
        )
    }
}
