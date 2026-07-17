//
//  EmailField.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

// MARK: - Email Field

struct EmailField: View {
    let title: String
    @Binding var text: String
    var errorMessage: String?
    var focus: FocusState<String?>.Binding?
    var focusTag: String?
    var submitLabel: SubmitLabel = .return
    var onSubmit: (() -> Void)?

    var body: some View {
        AppTextField(
            title: title,
            placeholder: String(localized: "you@example.com"),
            icon: AppIcons.email,
            text: $text,
            errorMessage: errorMessage,
            keyboardType: .emailAddress,
            textContentType: .emailAddress,
            autocapitalization: .never,
            focus: focus,
            focusTag: focusTag,
            submitLabel: submitLabel,
            onSubmit: onSubmit
        )
    }
}
