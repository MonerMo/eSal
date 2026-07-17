//
//  NetworkLogger.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - Network Logger

/// Debug-only HTTP request/response logging for the Xcode console.
///
/// Sensitive fields (`password`, `accessToken`, etc.) are redacted before printing.
enum NetworkLogger {

    private static let sensitiveKeys: Set<String> = [
        "password",
        "confirmPassword",
        "accessToken",
        "walletToken"
    ]

    // MARK: - Request

    static func logRequest(_ request: URLRequest) {
        #if DEBUG
        let method = request.httpMethod ?? "GET"
        let url = request.url?.absoluteString ?? "unknown URL"
        print("🌐 [REQUEST] \(method) \(url)")

        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            print("   Headers: \(sanitizeHeaders(headers))")
        }

        if let body = request.httpBody {
            print("   Body: \(sanitizeJSON(body))")
        }
        #endif
    }

    // MARK: - Response

    static func logResponse(data: Data, response: HTTPURLResponse) {
        #if DEBUG
        print("📥 [RESPONSE] \(response.statusCode) \(response.url?.absoluteString ?? "")")
        if let contentType = response.value(forHTTPHeaderField: "Content-Type"),
           contentType.contains("pkpass") {
            print("   Body: <pkpass binary, \(data.count) bytes>")
        } else {
            print("   Body: \(sanitizeJSON(data))")
        }
        #endif
    }

    // MARK: - Error

    static func logError(_ error: Error, url: URL?) {
        #if DEBUG
        print("❌ [NETWORK ERROR] \(url?.absoluteString ?? "") — \(error.localizedDescription)")
        #endif
    }

    // MARK: - Sanitization

    private static func sanitizeHeaders(_ headers: [String: String]) -> [String: String] {
        Dictionary(uniqueKeysWithValues: headers.map { key, value in
            (key, key.lowercased() == "authorization" ? "Bearer ***" : value)
        })
    }

    private static func sanitizeJSON(_ data: Data) -> String {
        guard
            let object = try? JSONSerialization.jsonObject(with: data),
            let sanitized = sanitize(object) as? [String: Any],
            let pretty = try? JSONSerialization.data(withJSONObject: sanitized, options: [.prettyPrinted, .sortedKeys]),
            let string = String(data: pretty, encoding: .utf8)
        else {
            return String(data: data, encoding: .utf8) ?? "<non-UTF8 body>"
        }
        return string
    }

    private static func sanitize(_ object: Any) -> Any {
        switch object {
        case var dictionary as [String: Any]:
            for key in dictionary.keys {
                if sensitiveKeys.contains(key) {
                    dictionary[key] = "***"
                } else if let nested = dictionary[key] {
                    dictionary[key] = sanitize(nested)
                }
            }
            return dictionary
        case let array as [Any]:
            return array.map { sanitize($0) }
        default:
            return object
        }
    }
}
