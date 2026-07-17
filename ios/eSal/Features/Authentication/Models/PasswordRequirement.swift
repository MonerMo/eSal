//
//  PasswordRequirement.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - Password Requirement

struct PasswordRequirement: Identifiable, Equatable {
    let id: String
    let label: String
    let isMet: Bool
}

enum PasswordValidator {

    static func requirements(password: String) -> [PasswordRequirement] {
        [
            PasswordRequirement(
                id: "length",
                label: String(localized: "At least 8 characters"),
                isMet: password.count >= 8
            ),
            PasswordRequirement(
                id: "uppercase",
                label: String(localized: "One uppercase letter"),
                isMet: password.rangeOfCharacter(from: .uppercaseLetters) != nil
            ),
            PasswordRequirement(
                id: "lowercase",
                label: String(localized: "One lowercase letter"),
                isMet: password.rangeOfCharacter(from: .lowercaseLetters) != nil
            ),
            PasswordRequirement(
                id: "special",
                label: String(localized: "One special character"),
                isMet: containsSpecialCharacter(password)
            )
        ]
    }

    static func isValid(password: String) -> Bool {
        requirements(password: password).allSatisfy(\.isMet)
    }

    private static func containsSpecialCharacter(_ password: String) -> Bool {
        let specials = CharacterSet.punctuationCharacters.union(.symbols)
        return password.unicodeScalars.contains { specials.contains($0) }
    }
}
