//
//  AppAlert.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

// MARK: - App Alert Data

struct AppAlertData: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let message: String
    let primaryButtonTitle: String
    let secondaryButtonTitle: String?
    let isDestructive: Bool
}

// MARK: - App Alert Modifier

struct AppAlertModifier: ViewModifier {
    @Binding var alert: AppAlertData?
    var primaryAction: (() -> Void)?
    var secondaryAction: (() -> Void)?

    private var isPresented: Binding<Bool> {
        Binding(
            get: { alert != nil },
            set: { if !$0 { alert = nil } }
        )
    }

    func body(content: Content) -> some View {
        content
            .confirmationDialog(
                alert?.title ?? "",
                isPresented: isPresented,
                titleVisibility: .visible
            ) {
                if let data = alert {
                    Button(data.primaryButtonTitle, role: data.isDestructive ? .destructive : nil) {
                        primaryAction?()
                    }
                    if let secondaryTitle = data.secondaryButtonTitle {
                        Button(secondaryTitle, role: .cancel) {
                            secondaryAction?()
                        }
                    }
                }
            } message: {
                if let message = alert?.message {
                    Text(message)
                }
            }
    }
}

extension View {
    func appAlert(
        _ alert: Binding<AppAlertData?>,
        primaryAction: (() -> Void)? = nil,
        secondaryAction: (() -> Void)? = nil
    ) -> some View {
        modifier(AppAlertModifier(alert: alert, primaryAction: primaryAction, secondaryAction: secondaryAction))
    }
}
