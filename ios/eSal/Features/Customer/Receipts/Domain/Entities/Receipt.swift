//
//  Receipt.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - Receipt

/// Customer receipt domain model mapped from `GET /receipts`.
struct Receipt: Identifiable, Hashable, Sendable {
    let id: String
    let storeName: String
    let storeLogoURL: String?
    let invoiceNumber: String?
    let taxId: String?
    let createdAt: Date
    let transactionDate: Date?
    let subtotal: Decimal
    let tax: Decimal?
    let serviceCharge: Decimal?
    let discount: Decimal?
    let total: Decimal
    let paymentMethod: String?
    let status: String
    let items: [ReceiptLineItem]
}

// MARK: - Receipt Line Item

struct ReceiptLineItem: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let quantity: Decimal
    let unitPrice: Decimal
    let totalPrice: Decimal
    let warrantyEndDate: Date?
    let categoryName: String?
}

// MARK: - Display Formatting

extension Receipt {
    static let currencyCode = "SAR"

    var receiptNumber: String { invoiceNumber ?? "—" }
    var formattedTotal: String { Self.formatMoney(total) }
    var formattedVAT: String { Self.formatMoney(tax ?? 0) }
    var displayDate: Date? { transactionDate }
    var formattedDate: String {
        guard let transactionDate else { return String(localized: "—") }
        return transactionDate.formatted(date: .abbreviated, time: .shortened)
    }
    var paymentMethodDisplay: String { paymentMethod ?? String(localized: "—") }
    var taxIdDisplay: String { taxId ?? "—" }
    var currency: String { Self.currencyCode }
    var itemCount: Int { items.count }

    var formattedItemCount: String {
        String(localized: "\(itemCount) items")
    }

    var statusDisplay: String {
        switch status.uppercased() {
        case "ASSIGNED":
            String(localized: "Assigned")
        case "PENDING":
            String(localized: "Pending")
        default:
            status
        }
    }

    static func formatMoney(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: value as NSDecimalNumber) ?? "\(value) \(currencyCode)"
    }
}

extension ReceiptLineItem {
    var quantityDisplay: String {
        NSDecimalNumber(decimal: quantity).stringValue
    }

    func formattedLineTotal() -> String {
        Receipt.formatMoney(totalPrice)
    }
}

// MARK: - Preview Sample

extension Receipt {
    static let sample = Receipt(
        id: "preview",
        storeName: "MonirElectronics",
        storeLogoURL: nil,
        invoiceNumber: "INV-88213",
        taxId: nil,
        createdAt: .now,
        transactionDate: .now,
        subtotal: 635,
        tax: nil,
        serviceCharge: nil,
        discount: nil,
        total: 635,
        paymentMethod: "VISA ****1234",
        status: "ASSIGNED",
        items: [
            ReceiptLineItem(
                id: "1",
                name: "Matcha Latte",
                quantity: 1,
                unitPrice: 25,
                totalPrice: 25,
                warrantyEndDate: nil,
                categoryName: "Coffee & Beverages"
            ),
            ReceiptLineItem(
                id: "2",
                name: "Apple Pencil 2nd Gen",
                quantity: 1,
                unitPrice: 529,
                totalPrice: 529,
                warrantyEndDate: Calendar.current.date(
                    byAdding: DateComponents(year: 1, month: 3, day: 14),
                    to: .now
                ),
                categoryName: "Electronics"
            )
        ]
    )
}
