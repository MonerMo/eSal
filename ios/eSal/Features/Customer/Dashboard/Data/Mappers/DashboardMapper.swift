//
//  DashboardMapper.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import Foundation

// MARK: - Dashboard Mapper

enum DashboardMapper {

    static func map(_ dto: DashboardDTO) -> Dashboard {
        let recentReceipts = dto.recentReceipts.map(ReceiptMapper.map)

        return Dashboard(
            firstName: dto.firstName,
            totalSpendingThisMonth: dto.totalSpendingThisMonth.value,
            nearestWarranty: map(dto.nearestWarranty, recentReceipts: recentReceipts),
            recentReceipts: Array(recentReceipts.prefix(3)),
            smartOffers: dto.smartOffers.enumerated().map { mapOffer($0.element, index: $0.offset) }
        )
    }

    private static func map(
        _ dto: DashboardNearestWarrantyDTO?,
        recentReceipts: [Receipt]
    ) -> DashboardWarranty? {
        guard let dto else { return nil }

        let receipt = dto.receipt.map(ReceiptMapper.map)
            ?? recentReceipts.first(where: { $0.id == dto.receiptId })

        guard let receipt else { return nil }

        return DashboardWarranty(
            itemName: dto.itemName,
            storeName: dto.storeName,
            warrantyEndDate: dto.warrantyEndDate,
            receipt: receipt
        )
    }

    private static func mapOffer(_ dto: SmartOfferDTO, index: Int) -> SmartOffer {
        SmartOffer(
            id: dto.id ?? "offer-\(index)",
            title: dto.title,
            description: dto.description,
            imageURL: dto.imageUrl
        )
    }
}
