//
//  NFCLinkParser.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - NFC Link Parser

enum NFCLinkParser {

    static func parse(_ url: URL) -> NFCLinkIntent? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return nil
        }

        guard isNFCLink(components: components) else {
            return nil
        }

        guard let pairingId = queryValue(named: "pairingId", in: components)?
            .trimmingCharacters(in: .whitespacesAndNewlines),
            !pairingId.isEmpty else {
            return nil
        }

        guard let modeRaw = queryValue(named: "mode", in: components),
              let mode = NFCLinkMode(rawValue: modeRaw) else {
            return nil
        }

        return NFCLinkIntent(pairingId: pairingId, mode: mode)
    }

    private static func isNFCLink(components: URLComponents) -> Bool {
        if components.scheme?.lowercased() == "esal" {
            return components.host?.lowercased() == "nfc"
        }

        return isNFCLinkPath(components.path)
    }

    private static func isNFCLinkPath(_ path: String) -> Bool {
        path == "/nfc" || path.hasSuffix("/nfc")
    }

    private static func queryValue(named name: String, in components: URLComponents) -> String? {
        components.queryItems?.first(where: { $0.name == name })?.value
    }
}
