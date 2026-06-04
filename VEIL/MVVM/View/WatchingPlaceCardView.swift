//
//  WatchingPlaceCardView.swift
//  VEIL
//

import SwiftUI

struct WatchingPlaceCardView: View {

    let place: Place
    let colorIndex: Int

    var body: some View {
        ZStack(alignment: .topLeading) {

            folderBackground

            VStack(alignment: .leading, spacing: 8) {

                Spacer()

                Text(place.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color("TitleColor"))

                Text("Day \(place.currentDay) of \(place.activeDays) · in observation")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color("SubtitleColor"))
            }
            .padding(.horizontal, 20)
            .padding(.top, 34)
            .padding(.bottom, 20)
        }
        .frame(width: 240, height: 170)
    }

    private var folderBackground: some View {
        ZStack(alignment: .topLeading) {

            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(placeTint.opacity(0.95))
                .frame(height: 135)
                .offset(y: 28)

            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(placeTint)
                .frame(width: 96, height: 42)
                .offset(x: 0, y: 12)

            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.22))
                .padding(.horizontal, 12)
                .padding(.top, 42)
                .padding(.bottom, 18)

            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(
                    placeTint.opacity(0.95),
                    lineWidth: 1.2
                )
                .frame(height: 135)
                .offset(y: 28)
        }
    }

    private var placeTint: Color {
        let colors: [Color] = [
            Color(red: 0.93, green: 0.92, blue: 0.58), // Yellow
            Color(red: 0.83, green: 0.86, blue: 0.92), // Blue
            Color(red: 0.82, green: 0.88, blue: 0.82)  // Green
        ]

        let safeIndex = min(max(colorIndex, 0), colors.count - 1)
        return colors[safeIndex]
    }
}
