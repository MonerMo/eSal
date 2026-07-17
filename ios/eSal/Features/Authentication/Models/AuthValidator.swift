//
//  AuthValidator.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - Auth Validator

/// Small, reusable validation helpers shared by the auth view models.
enum AuthValidator {

    static func isValidEmail(_ email: String) -> Bool {
        let pattern = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return email.trimmed.range(of: pattern, options: .regularExpression) != nil
    }

    static func isValidPhone(_ phone: String) -> Bool {
        let pattern = "^05\\d{8}$"
        return phone.range(of: pattern, options: .regularExpression) != nil
    }

    /// Keeps only digits, enforces a `05` prefix while typing, and caps at 10 digits.
    static func filteredPhoneInput(_ input: String) -> String {
        let digits = input.filter(\.isNumber)
        var result = ""

        for digit in digits {
            let candidate = result + String(digit)
            guard isAllowedPhonePrefix(candidate) else { continue }
            result = candidate
            if result.count == 10 { break }
        }

        return result
    }

    private static func isAllowedPhonePrefix(_ value: String) -> Bool {
        switch value.count {
        case 0:
            true
        case 1:
            value == "0"
        case 2:
            value == "05"
        case 3...10:
            value.hasPrefix("05")
        default:
            false
        }
    }
}

// MARK: - String Helpers

extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isBlank: Bool {
        trimmed.isEmpty
    }
}
