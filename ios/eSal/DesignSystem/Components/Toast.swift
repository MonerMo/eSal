//
//  Toast.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

// MARK: - Toast Style

enum ToastStyle: Sendable {
    case success
    case error
    case info

    var icon: String {
        switch self {
        case .success: AppIcons.checkmark
        case .error: AppIcons.error
        case .info: "info.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .success: AppColors.success
        case .error: AppColors.error
        case .info: AppColors.p100
        }
    }
}

// MARK: - Toast Data

struct ToastData: Equatable, Sendable {
    let message: String
    let style: ToastStyle
}

// MARK: - Toast View

struct ToastView: View {
    let data: ToastData

    var body: some View {
        HStack(spacing: Theme.Spacing.small) {
            Image(systemName: data.style.icon)
                .foregroundStyle(data.style.color)

            Text(data.message)
                .font(AppTypography.subheadline)
                .foregroundStyle(AppColors.primaryText)
        }
        .padding(.horizontal, Theme.Spacing.medium)
        .padding(.vertical, Theme.Spacing.small)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                .stroke(AppColors.border.opacity(0.25), lineWidth: 0.5)
        }
        .shadow(color: AppColors.cardShadow(for: .light, opacity: 0.12), radius: Theme.Shadow.cardRadius)
        .accessibilityLabel(data.message)
    }
}

// MARK: - Toast Modifier

struct ToastModifier: ViewModifier {
    @Binding var toast: ToastData?

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if let toast {
                    ToastView(data: toast)
                        .padding(.horizontal, Theme.Spacing.large)
                        .padding(.top, Theme.Spacing.large)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .onAppear {
                            Task {
                                try? await Task.sleep(nanoseconds: 3_000_000_000)
                                withAnimation { self.toast = nil }
                            }
                        }
                }
            }
            .animation(.easeInOut(duration: Theme.Animation.standard), value: toast)
    }
}

extension View {
    func toast(_ toast: Binding<ToastData?>) -> some View {
        modifier(ToastModifier(toast: toast))
    }
}
