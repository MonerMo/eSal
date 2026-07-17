//
//  RegisterAccountTypeView.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

// MARK: - Register Account Type View

/// Account type selection content for the registration flow.
struct RegisterAccountTypeView: View {

    let onSelect: (AccountType) -> Void

    var body: some View {
        VStack(spacing: Theme.Spacing.xLarge) {
            SectionHeader(
                String(localized: "Choose Account Type"),
                subtitle: String(localized: "Select how you'd like to use eSal")
            )

            VStack(spacing: Theme.Spacing.xxLarge) {
                AccountTypeButton(
                    title: String(localized: "Register as Customer"),
                    subtitle: String(localized: "Manage and analyze your digital receipts"),
                    icon: AppIcons.customer
                ) {
                    onSelect(.customer)
                }

                AccountTypeButton(
                    title: String(localized: "Register as Shop"),
                    subtitle: String(localized: "Issue receipts and monitor your store sales"),
                    icon: AppIcons.shop
                ) {
                    onSelect(.shop)
                }
            }
        }
    }
}
