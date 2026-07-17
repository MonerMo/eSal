//
//  PasswordField.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

// MARK: - Password Field

struct PasswordField: View {
    let title: String
    @Binding var text: String
    var errorMessage: String?
    var focus: FocusState<String?>.Binding?
    var focusTag: String?
    var submitLabel: SubmitLabel = .return
    var onSubmit: (() -> Void)?

    var body: some View {
        SecureTextField(
            title: title,
            placeholder: String(localized: "Password"),
            text: $text,
            errorMessage: errorMessage,
            focus: focus,
            focusTag: focusTag,
            submitLabel: submitLabel,
            onSubmit: onSubmit
        )
    }
}
