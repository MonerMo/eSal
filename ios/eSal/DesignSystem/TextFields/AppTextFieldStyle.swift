//
//  AppTextFieldStyle.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

// MARK: - App Text Field Style

enum AppTextFieldStyle {
    static func prompt(_ text: String) -> Text {
        Text(text).foregroundStyle(AppColors.g200)
    }

    static var inputForeground: Color { AppColors.f100 }
}
