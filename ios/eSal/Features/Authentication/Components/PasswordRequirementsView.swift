//
//  PasswordRequirementsView.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

// MARK: - Password Requirements View

struct PasswordRequirementsView: View {
    let requirements: [PasswordRequirement]

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xxSmall) {
            ForEach(requirements) { requirement in
                HStack(spacing: Theme.Spacing.xSmall) {
                    Image(systemName: AppIcons.checkmark)
                        .font(.system(size: Theme.IconSize.small))
                        .foregroundStyle(requirement.isMet ? AppColors.success : AppColors.disabled)

                    Text(requirement.label)
                        .font(AppTypography.caption)
                        .foregroundStyle(requirement.isMet ? AppColors.primaryText : AppColors.secondaryText)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
