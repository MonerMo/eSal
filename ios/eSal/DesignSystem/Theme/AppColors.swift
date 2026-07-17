//
//  AppColors.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

// MARK: - App Colors

enum AppColors {
    static let p100 = Color("p100", bundle: .main)
    static let f100 = Color("f100", bundle: .main)
    static let g100 = Color("g100", bundle: .main)
    static let g200 = Color("g200", bundle: .main)

    static let background = Color("Background", bundle: .main)
    static let cardBackground = Color("CardBackground", bundle: .main)
    static let accent = Color.accentColor

    static let primaryText = f100
    static let secondaryText = g100
    static let tertiaryText = Color(.tertiaryLabel)

    static let surfaceMuted = cardBackground.opacity(0.72)

    static let success = p100.opacity(0.92)
    static let warning = Color(red: 0.95, green: 0.58, blue: 0.12)
    static let error = Color(red: 0.88, green: 0.22, blue: 0.24)
    static let border = Color(.separator)
    static let disabled = Color(.systemGray3)

    static let onPrimary = Color.white

    static func cardShadow(for colorScheme: ColorScheme, opacity: Double = 0.08) -> Color {
        colorScheme == .dark ? .clear : .black.opacity(opacity)
    }
}
