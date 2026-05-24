//
//  WatchingPlaceCardView.swift
//  VEIL
//

import SwiftUI

struct WatchingPlaceCardView: View {

    let place: WatchingPlace

    var body: some View {
        ZStack(alignment: .topLeading) {

            folderBackground

            VStack(alignment: .leading, spacing: 8) {

                /*HStack {
                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color("SubtitleColor"))
                }*/

                Spacer()

                Text(place.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color("TitleColor"))

                Text("Day \(place.currentDay) of \(place.totalDays) · in observation")
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
                .fill(place.tint.opacity(0.95))
                .frame(height: 135)
                .offset(y: 28)

            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(place.tint)
                .frame(width: 96, height: 42)
                .offset(x: 0, y: 12)

            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.22))
                .padding(.horizontal, 12)
                .padding(.top, 42)
                .padding(.bottom, 18)

            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(
                    place.tint.opacity(0.95),
                    lineWidth: 1.2
                )
                .frame(height: 135)
                .offset(y: 28)
        }
    }
}
