//
//  Theme.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

// MARK: - Theme

enum Theme {

    // MARK: - Spacing

    enum Spacing {
        static let xxSmall: CGFloat = 4
        static let xSmall: CGFloat = 8
        static let small: CGFloat = 12
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let xLarge: CGFloat = 32
        static let xxLarge: CGFloat = 48
    }

    // MARK: - Radius

    enum Radius {
        static let small: CGFloat = 10
        static let medium: CGFloat = 14
        static let large: CGFloat = 18
        static let xLarge: CGFloat = 24
        static let pill: CGFloat = 999
    }

    // MARK: - Icon Size

    enum IconSize {
        static let small: CGFloat = 16
        static let medium: CGFloat = 22
        static let large: CGFloat = 32
        static let hero: CGFloat = 64
    }

    // MARK: - Animation

    enum Animation {
        static let fast: Double = 0.18
        static let standard: Double = 0.28
        static let slow: Double = 0.45
    }

    // MARK: - Shadow

    enum Shadow {
        static let cardRadius: CGFloat = 10
        static let cardYOffset: CGFloat = 3
    }

    // MARK: - Layout

    enum Layout {
        static let minTapTarget: CGFloat = 44
        static let maxContentWidth: CGFloat = 640
    }
}
