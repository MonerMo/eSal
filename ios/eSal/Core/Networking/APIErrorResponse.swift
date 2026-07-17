//
//  APIErrorResponse.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - API Error Response

/// Matches the NestJS error envelope returned by esal.onrender.com.
struct APIErrorResponse: Decodable {
    let message: Message
    let error: String?
    let statusCode: Int?

    enum Message: Decodable {
        case single(String)
        case multiple([String])

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let string = try? container.decode(String.self) {
                self = .single(string)
            } else if let array = try? container.decode([String].self) {
                self = .multiple(array)
            } else {
                self = .single(String(localized: "Something went wrong."))
            }
        }

        var displayText: String {
            switch self {
            case .single(let text): text
            case .multiple(let texts): texts.joined(separator: "\n")
            }
        }
    }
}

// MARK: - API Error Parser

enum APIErrorParser {
    static func message(from data: Data, fallbackStatusCode: Int) -> String {
        let messages = validationMessages(from: data)
        if !messages.isEmpty {
            return messages.joined(separator: "\n")
        }
        return String(localized: "Request failed (\(fallbackStatusCode)).")
    }

    static func validationMessages(from data: Data) -> [String] {
        guard let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: data) else {
            return []
        }

        switch apiError.message {
        case .single(let text) where !text.isEmpty:
            return [text]
        case .multiple(let texts):
            return texts.filter { !$0.isEmpty }
        default:
            return []
        }
    }
}
