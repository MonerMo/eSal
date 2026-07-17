//
//  CardView.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

// MARK: - Card Style

enum CardStyle {
    case surface
    case primary

    var backgroundColor: Color {
        switch self {
        case .surface:
            AppColors.cardBackground
        case .primary:
            AppColors.p100
        }
    }
}

// MARK: - Card View

struct CardView<Content: View>: View {
    let style: CardStyle
    let content: Content

    @Environment(\.colorScheme) private var colorScheme

    init(style: CardStyle = .surface, @ViewBuilder content: () -> Content) {
        self.style = style
        self.content = content()
    }

    var body: some View {
        content
            .padding(Theme.Spacing.medium)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(style.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous))
            .overlay {
                if style == .surface {
                    RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous)
                        .stroke(AppColors.border.opacity(colorScheme == .dark ? 0.35 : 0.18), lineWidth: 0.5)
                }
            }
            .shadow(
                color: AppColors.cardShadow(for: colorScheme, opacity: style == .primary ? 0.12 : 0.07),
                radius: Theme.Shadow.cardRadius,
                y: Theme.Shadow.cardYOffset
            )
    }
}
