//
//  ReceiptMapper.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - Receipt Mapper

enum ReceiptMapper {

    static func map(_ response: ReceiptListResponseDTO) -> ReceiptListResult {
        ReceiptListResult(
            receipts: response.data.map(map),
            pagination: map(response.pagination)
        )
    }

    static func map(_ dto: ReceiptDTO) -> Receipt {
        Receipt(
            id: dto.id,
            storeName: dto.device?.displayName ?? String(localized: "Unknown Store"),
            storeLogoURL: dto.device?.logoUrl,
            invoiceNumber: dto.invoiceNo,
            taxId: dto.device?.taxId,
            createdAt: dto.createdAt,
            transactionDate: dto.transactionDate,
            subtotal: dto.subtotal.value,
            tax: dto.tax?.value,
            serviceCharge: dto.serviceCharge?.value,
            discount: dto.discount?.value,
            total: dto.total.value,
            paymentMethod: dto.paymentMethod,
            status: dto.status,
            items: dto.lineItems.map(map)
        )
    }

    private static func map(_ dto: ReceiptLineItemDTO) -> ReceiptLineItem {
        ReceiptLineItem(
            id: dto.id,
            name: dto.name,
            quantity: dto.quantity.value,
            unitPrice: dto.unitPrice.value,
            totalPrice: dto.totalPrice.value,
            warrantyEndDate: dto.warrantyEndDate,
            categoryName: dto.category?.name
        )
    }

    private static func map(_ dto: ReceiptPaginationDTO) -> ReceiptPagination {
        ReceiptPagination(
            page: dto.page,
            pageSize: dto.pageSize,
            total: dto.total,
            totalPages: dto.totalPages
        )
    }
}
