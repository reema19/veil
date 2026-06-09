//
//  HomeHeaderView.swift
//  VEIL
//

import SwiftUI

struct HomeHeaderView: View {

    let userName: String
    var onProfileTap: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var isAccessibilitySize: Bool {
        dynamicTypeSize.isAccessibilitySize
    }

    private var buttonSize: CGFloat {
        isAccessibilitySize ? 62 : 58
    }

    var body: some View {
        HStack(alignment: .center, spacing: 16) {

            Text("Good morning, \(userName)")
                .font(.custom("DMSans-Bold", size: 24, relativeTo: .title2))
                .foregroundColor(Color("TitleColor"))
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)

            Button(action: onProfileTap) {
                headerProfileIcon
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open profile")
            .accessibilityHint("Opens your profile settings")
        }
        .frame(maxWidth: .infinity)
    }

    private var headerProfileIcon: some View {
        Image(systemName: "person.crop.circle")
            .font(.system(size: 23, weight: .medium))
            .foregroundColor(Color("TitleColor"))
            .frame(width: buttonSize, height: buttonSize)
            .background(.ultraThinMaterial)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .strokeBorder(
                        Color("TitleColor").opacity(0.08),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: .black.opacity(0.08),
                radius: 12,
                x: 0,
                y: 6
            )
    }
}
