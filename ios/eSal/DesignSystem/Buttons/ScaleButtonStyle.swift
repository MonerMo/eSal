//
//  ScaleButtonStyle.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

// MARK: - Scale Button Style

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.92 : 1)
            .animation(.easeOut(duration: Theme.Animation.fast), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == ScaleButtonStyle {
    static var appScale: ScaleButtonStyle { ScaleButtonStyle() }
}
