//
//  SenseCardView.swift
//  VEIL
//
//  Created by Ghady Al Omar on 06/12/1447 AH.
//

import SwiftUI

struct SenseCardView: View {
    let sense: SenseType

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 26)
                .fill(.white)
                .overlay(
                    RadialGradient(
                        colors: [Color(sense.colorName).opacity(0.8), .clear],
                        center: .center,
                        startRadius: 20,
                        endRadius: 100
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 26))
                )
                .shadow(color: .black.opacity(0.2), radius: 16, x: 0, y: 6)

            VStack(spacing: 14) {
                Image(systemName: sense.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: sense.iconSize.width,
                        height: sense.iconSize.height
                    )
                    .foregroundStyle(Color.gray)

                Text(sense.title)
                    .font(.custom("DMSans-Bold", size: 25))
                    .foregroundColor(Color(hex: "#2C1E0F"))

                Text(sense.description)
                    .font(.system(size: 13))
                    .foregroundStyle(Color(hex: "#666666"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(24)
        }
        .frame(width: 270, height: 180)
    }
}
#Preview {
    SenseCardView(sense: .sight)
    SenseCardView(sense: .sound)
}
