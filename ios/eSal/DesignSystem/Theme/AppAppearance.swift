//
//  AppAppearance.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

// MARK: - App Chrome

extension View {
    func appDefaultTextColor() -> some View {
        foregroundStyle(AppColors.f100)
    }

    func appNavigationBarStyle() -> some View {
        toolbarBackground(AppColors.background, for: .navigationBar)
    }

    func appSearchNavigationBarStyle() -> some View {
        toolbarBackground(AppColors.background, for: .automatic)
            .toolbarBackground(.visible, for: .automatic)
    }

    func appLargeNavigationTitle(_ title: String) -> some View {
        navigationTitle(title)
            .navigationBarTitleDisplayMode(.large)
            .appNavigationBarStyle()
    }

    func appTabBarStyle() -> some View {
        toolbarBackground(AppColors.background, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
    }

    func appScreenStyle() -> some View {
        background(AppColors.background.ignoresSafeArea())
            .tint(AppColors.p100)
    }

    func appContentWidth() -> some View {
        frame(maxWidth: Theme.Layout.maxContentWidth)
        .frame(maxWidth: .infinity)
    }

    func appListAppearAnimation(index: Int = 0) -> some View {
        modifier(AppListAppearModifier(index: index))
    }
}

// MARK: - List Appear Animation

private struct AppListAppearModifier: ViewModifier {
    let index: Int
    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 8)
            .onAppear {
                withAnimation(.easeOut(duration: Theme.Animation.standard).delay(Double(index) * 0.04)) {
                    isVisible = true
                }
            }
    }
}
