//
//  SecureTextField.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

// MARK: - Secure Text Field

struct SecureTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var errorMessage: String?
    var focus: FocusState<String?>.Binding?
    var focusTag: String?
    var submitLabel: SubmitLabel = .return
    var onSubmit: (() -> Void)?

    @State private var isSecure = true

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
            Text(title)
                .font(AppTypography.subheadline)
                .foregroundStyle(AppColors.secondaryText)

            HStack(spacing: Theme.Spacing.small) {
                Image(systemName: AppIcons.password)
                    .foregroundStyle(AppColors.secondaryText)

                textField

                Button {
                    isSecure.toggle()
                } label: {
                    Image(systemName: isSecure ? "eye.slash" : "eye")
                        .foregroundStyle(AppColors.secondaryText)
                }
            }
            .padding(Theme.Spacing.medium)
            .background(AppColors.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.medium)
                    .stroke(errorMessage == nil ? AppColors.border : AppColors.error, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.medium))

            if let errorMessage {
                Text(errorMessage)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.error)
            }
        }
    }

    @ViewBuilder
    private var textField: some View {
        let field = Group {
            if isSecure {
                SecureField("", text: $text, prompt: AppTextFieldStyle.prompt(placeholder))
            } else {
                TextField("", text: $text, prompt: AppTextFieldStyle.prompt(placeholder))
            }
        }
        .foregroundStyle(AppTextFieldStyle.inputForeground)
        .textContentType(.password)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
        .submitLabel(submitLabel)
        .onSubmit { onSubmit?() }

        if let focus, let focusTag {
            field.focused(focus, equals: focusTag)
        } else {
            field
        }
    }
}
