//
//  AppTypography.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

// MARK: - App Typography

/// SF Mono via the system monospaced design — consistent across the app.
enum AppTypography {

    static let logo = mono(size: 100, weight: .regular)
    static let welcome = mono(size: 24, weight: .regular)

    static let largeTitle = mono(.largeTitle, weight: .bold)
    static let title = mono(.title2, weight: .semibold)
    static let sectionTitle = mono(.title3, weight: .semibold)
    static let statValue = mono(.title, weight: .bold)

    static let headline = mono(size: 16, weight: .semibold)
    static let body = mono(.body, weight: .regular)
    static let callout = mono(.callout, weight: .regular)
    static let subheadline = mono(size: 13, weight: .regular)
    static let footnote = mono(.footnote, weight: .regular)
    static let caption = mono(.caption, weight: .regular)
    static let button = mono(size: 17, weight: .semibold)

    private static func mono(_ style: Font.TextStyle, weight: Font.Weight = .regular) -> Font {
        Font.system(style, design: .monospaced).weight(weight)
    }

    private static func mono(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        Font.system(size: size, weight: weight, design: .monospaced)
    }
}
