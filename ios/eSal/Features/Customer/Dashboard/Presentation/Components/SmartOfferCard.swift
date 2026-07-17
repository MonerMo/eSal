//
//  SmartOfferCard.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

// MARK: - Smart Offer Card

struct SmartOfferCard: View {
    let offer: SmartOffer

    @Environment(\.colorScheme) private var colorScheme

    private let cardWidth: CGFloat = 272

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            if offer.imageURL != nil {
                offerImage
            } else {
                placeholder
            }

            Text(offer.title)
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.onPrimary)
                .lineLimit(2)

            Text(offer.description)
                .font(AppTypography.subheadline)
                .foregroundStyle(AppColors.onPrimary.opacity(0.9))
                .lineLimit(3)
        }
        .padding(Theme.Spacing.medium)
        .frame(width: cardWidth, alignment: .leading)
        .background(offerBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous))
        .shadow(
            color: AppColors.cardShadow(for: colorScheme, opacity: 0.1),
            radius: Theme.Shadow.cardRadius,
            y: Theme.Shadow.cardYOffset
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(offer.title), \(offer.description)")
    }

    @ViewBuilder
    private var offerImage: some View {
        if let imageURL = offer.imageURL, let url = URL(string: imageURL) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure, .empty:
                    placeholder
                @unknown default:
                    placeholder
                }
            }
            .frame(height: 96)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous))
        } else {
            placeholder
        }
    }

    private var placeholder: some View {
        RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
            .fill(AppColors.onPrimary.opacity(0.14))
            .frame(height: 96)
            .overlay {
                Image(systemName: "tag.fill")
                    .font(.system(size: Theme.IconSize.large))
                    .foregroundStyle(AppColors.onPrimary.opacity(0.9))
            }
    }

    private var offerBackground: some View {
        LinearGradient(
            colors: [
                AppColors.p100,
                AppColors.p100.opacity(0.78)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

#Preview {
    ScrollView(.horizontal) {
        SmartOfferCard(offer: Dashboard.sample.smartOffers[0])
    }
    .padding()
}
