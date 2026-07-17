//
//  ReceiptDTO.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - List Response DTO

struct ReceiptListResponseDTO: Decodable, Sendable {
    let data: [ReceiptDTO]
    let pagination: ReceiptPaginationDTO
}

struct ReceiptPaginationDTO: Decodable, Sendable {
    let page: Int
    let pageSize: Int
    let total: Int
    let totalPages: Int
}

// MARK: - Receipt DTO

struct ReceiptDTO: Decodable, Sendable {
    let id: String
    let subtotal: DecimalString
    let tax: DecimalString?
    let serviceCharge: DecimalString?
    let discount: DecimalString?
    let total: DecimalString
    let paymentMethod: String?
    let invoiceNo: String?
    let transactionDate: Date?
    let status: String
    let createdAt: Date
    let device: ReceiptDeviceDTO?
    let lineItems: [ReceiptLineItemDTO]

    enum CodingKeys: String, CodingKey {
        case id
        case subtotal
        case tax
        case serviceCharge
        case discount
        case total
        case paymentMethod
        case invoiceNo
        case transactionDate
        case status
        case createdAt
        case device
        case lineItems
        case aiOutput
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let aiOutput = try container.decodeIfPresent(ReceiptAIOutputDTO.self, forKey: .aiOutput)

        id = try container.decode(String.self, forKey: .id)
        subtotal = try container.decodeIfPresent(DecimalString.self, forKey: .subtotal)
            ?? aiOutput?.subtotal
            ?? DecimalString(0)
        tax = try container.decodeIfPresent(DecimalString.self, forKey: .tax) ?? aiOutput?.tax
        serviceCharge = try container.decodeIfPresent(DecimalString.self, forKey: .serviceCharge) ?? aiOutput?.serviceCharge
        discount = try container.decodeIfPresent(DecimalString.self, forKey: .discount) ?? aiOutput?.discount
        total = try container.decodeIfPresent(DecimalString.self, forKey: .total)
            ?? aiOutput?.total
            ?? DecimalString(0)
        paymentMethod = try container.decodeIfPresent(String.self, forKey: .paymentMethod) ?? aiOutput?.paymentMethod
        invoiceNo = try container.decodeIfPresent(String.self, forKey: .invoiceNo) ?? aiOutput?.invoiceNo
        transactionDate = try container.decodeIfPresent(Date.self, forKey: .transactionDate) ?? aiOutput?.transactionDate
        status = try container.decodeIfPresent(String.self, forKey: .status) ?? "ASSIGNED"
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        device = try container.decodeIfPresent(ReceiptDeviceDTO.self, forKey: .device)
        lineItems = try container.decodeIfPresent([ReceiptLineItemDTO].self, forKey: .lineItems)
            ?? aiOutput?.items
            ?? []
    }
}

private struct ReceiptAIOutputDTO: Decodable, Sendable {
    let subtotal: DecimalString?
    let tax: DecimalString?
    let serviceCharge: DecimalString?
    let discount: DecimalString?
    let total: DecimalString?
    let paymentMethod: String?
    let invoiceNo: String?
    let transactionDate: Date?
    let items: [ReceiptLineItemDTO]?
}

struct ReceiptDeviceDTO: Decodable, Sendable {
    let name: String?
    let store: ReceiptStoreDTO?

    var displayName: String {
        store?.name ?? name ?? String(localized: "Unknown")
    }

    var logoUrl: String? { store?.logoUrl }
    var taxId: String? { store?.taxId }
}

struct ReceiptStoreDTO: Decodable, Sendable {
    let name: String
    let logoUrl: String?
    let taxId: String?
}

struct ReceiptLineItemDTO: Decodable, Sendable {
    let id: String
    let name: String
    let quantity: DecimalString
    let unitPrice: DecimalString
    let totalPrice: DecimalString
    let warrantyEndDate: Date?
    let category: ReceiptCategoryDTO?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case quantity
        case unitPrice
        case totalPrice
        case warrantyEndDate
        case category
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        name = try container.decode(String.self, forKey: .name)
        quantity = try container.decode(DecimalString.self, forKey: .quantity)
        unitPrice = try container.decode(DecimalString.self, forKey: .unitPrice)
        totalPrice = try container.decode(DecimalString.self, forKey: .totalPrice)
        warrantyEndDate = try container.decodeIfPresent(Date.self, forKey: .warrantyEndDate)
        category = try container.decodeIfPresent(ReceiptCategoryDTO.self, forKey: .category)
    }
}

struct ReceiptCategoryDTO: Decodable, Sendable {
    let name: String

    enum CodingKeys: String, CodingKey {
        case name
    }

    init(from decoder: Decoder) throws {
        let singleValueContainer = try decoder.singleValueContainer()
        if let name = try? singleValueContainer.decode(String.self) {
            self.name = name
            return
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
    }
}
