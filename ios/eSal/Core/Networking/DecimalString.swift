//
//  DecimalString.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - Decimal String

/// Decodes Prisma `Decimal` fields that arrive as JSON strings (or occasionally numbers).
struct DecimalString: Codable, Hashable, Sendable {
    let value: Decimal

    init(_ value: Decimal) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let string = try? container.decode(String.self) {
            guard let decimal = Decimal(string: string) else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Invalid decimal string: \(string)"
                )
            }
            value = decimal
            return
        }

        if let intValue = try? container.decode(Int.self) {
            value = Decimal(intValue)
            return
        }

        if let doubleValue = try? container.decode(Double.self) {
            value = Decimal(doubleValue)
            return
        }

        throw DecodingError.typeMismatch(
            Decimal.self,
            DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "Expected decimal as String or number"
            )
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(NSDecimalNumber(decimal: value).stringValue)
    }
}
