//
//  StoreAvatarView.swift
//  eSal
//
//  Created by Raghad Mohsen
//

import SwiftUI

// MARK: - Store Avatar View

struct StoreAvatarView: View {
    let name: String
    let logoURL: String?
    var size: CGFloat = 48

    var body: some View {
        Group {
            if let logoURL, let url = URL(string: logoURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        letterAvatar
                    }
                }
            } else {
                letterAvatar
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }

    private var letterAvatar: some View {
        Circle()
            .fill(AppColors.p100.opacity(0.12))
            .overlay {
                Text(storeInitial)
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.p100)
            }
    }

    private var storeInitial: String {
        String(name.trimmingCharacters(in: .whitespacesAndNewlines).prefix(1)).uppercased()
    }
}

#Preview {
    HStack(spacing: Theme.Spacing.medium) {
        StoreAvatarView(name: "MonirElectronics", logoURL: nil)
        StoreAvatarView(name: "MonirElectronics", logoURL: nil, size: 70)
    }
    .padding()
}
