//
//  JSONDecoder+API.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - API JSON Decoder

extension JSONDecoder {

    /// Shared decoder for esal.onrender.com payloads.
    ///
    /// The backend returns ISO-8601 dates with fractional seconds
    /// (e.g. `2026-07-06T01:53:54.491Z`). The built-in `.iso8601` strategy
    /// does not reliably parse those on every OS version.
    static func api() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { containerDecoder in
            let container = try containerDecoder.singleValueContainer()
            let value = try container.decode(String.self)

            let withFractionalSeconds = ISO8601DateFormatter()
            withFractionalSeconds.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = withFractionalSeconds.date(from: value) {
                return date
            }

            let withoutFractionalSeconds = ISO8601DateFormatter()
            withoutFractionalSeconds.formatOptions = [.withInternetDateTime]
            if let date = withoutFractionalSeconds.date(from: value) {
                return date
            }

            let dateOnlyFormatter = DateFormatter()
            dateOnlyFormatter.calendar = Calendar(identifier: .gregorian)
            dateOnlyFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateOnlyFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            dateOnlyFormatter.dateFormat = "yyyy-MM-dd"
            if let date = dateOnlyFormatter.date(from: value) {
                return date
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid ISO-8601 date: \(value)"
            )
        }
        return decoder
    }
}
