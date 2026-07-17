//
//  NFCLinkMode.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - NFC Link Mode

enum NFCLinkMode: String, Codable, Sendable, Hashable {
    case pair
    case claim
}
