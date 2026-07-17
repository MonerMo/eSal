//
//  AppTextField.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

// MARK: - App Text Field

struct AppTextField: View {
    let title: String
    let placeholder: String
    let icon: String?
    @Binding var text: String
    var errorMessage: String?
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType?
    var autocapitalization: TextInputAutocapitalization = .sentences
    var focus: FocusState<String?>.Binding?
    var focusTag: String?
    var submitLabel: SubmitLabel = .return
    var onSubmit: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
            Text(title)
                .font(AppTypography.subheadline)
                .foregroundStyle(AppColors.secondaryText)

            HStack(spacing: Theme.Spacing.small) {
                if let icon {
                    Image(systemName: icon)
                        .foregroundStyle(AppColors.secondaryText)
                }

                textField
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
        let field = TextField("", text: $text, prompt: AppTextFieldStyle.prompt(placeholder))
            .foregroundStyle(AppTextFieldStyle.inputForeground)
            .keyboardType(keyboardType)
            .textContentType(textContentType)
            .textInputAutocapitalization(autocapitalization)
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
