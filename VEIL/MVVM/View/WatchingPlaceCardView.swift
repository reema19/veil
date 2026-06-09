//
//  WatchingPlaceCardView.swift
//  VEIL
//

import SwiftUI

struct WatchingPlaceCardView: View {

    let place: Place
    let colorIndex: Int

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var isAccessibilitySize: Bool {
        dynamicTypeSize.isAccessibilitySize
    }

    private var cardWidth: CGFloat {
        isAccessibilitySize ? 280 : 240
    }

    private var cardHeight: CGFloat {
        isAccessibilitySize ? 210 : 170
    }

    private var folderHeight: CGFloat {
        isAccessibilitySize ? 168 : 135
    }

    private var momentCount: Int {
        place.observations.count
    }

    private var statusText: String {
        let momentText: String

        if momentCount == 0 {
            momentText = "no moments"
        } else if momentCount == 1 {
            momentText = "1 moment"
        } else {
            momentText = "\(momentCount) moments"
        }

        return "Day \(place.currentDay) of \(place.activeDays) · \(momentText)"
    }

    var body: some View {
        ZStack(alignment: .topLeading) {

            folderBackground

            VStack(alignment: .leading, spacing: isAccessibilitySize ? 8 : 6) {

                Spacer(minLength: 0)

                Text(place.name)
                    .font(.custom("DMSans-SemiBold", size: 14, relativeTo: .headline))
                    .foregroundColor(Color("TitleColor"))
                    .lineLimit(isAccessibilitySize ? 3 : 2)
                    .fixedSize(horizontal: false, vertical: true)

                Text(statusText)
                    .font(.custom("DMSans-Regular", size: 12, relativeTo: .caption))
                    .foregroundColor(Color("SubtitleColor"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
            .padding(.horizontal, isAccessibilitySize ? 22 : 20)
            .padding(.top, isAccessibilitySize ? 44 : 34)
            .padding(.bottom, isAccessibilitySize ? 26 : 24)
        }
        .frame(width: cardWidth, height: cardHeight)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(place.name), \(statusText)")
    }

    private var folderBackground: some View {
        ZStack(alignment: .topLeading) {

            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(placeTint.opacity(0.95))
                .frame(height: folderHeight)
                .offset(y: isAccessibilitySize ? 32 : 28)

            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(placeTint)
                .frame(
                    width: isAccessibilitySize ? 112 : 96,
                    height: isAccessibilitySize ? 48 : 42
                )
                .offset(x: 0, y: 12)

            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.22))
                .padding(.horizontal, 12)
                .padding(.top, isAccessibilitySize ? 50 : 42)
                .padding(.bottom, 18)

            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(
                    placeTint.opacity(0.95),
                    lineWidth: 1.2
                )
                .frame(height: folderHeight)
                .offset(y: isAccessibilitySize ? 32 : 28)
        }
    }

    private var placeTint: Color {
        let colors: [Color] = [
            Color(red: 0.93, green: 0.92, blue: 0.58),
            Color(red: 0.83, green: 0.86, blue: 0.92),
            Color(red: 0.82, green: 0.88, blue: 0.82)
        ]

        let safeIndex = min(max(colorIndex, 0), colors.count - 1)
        return colors[safeIndex]
    }
}
