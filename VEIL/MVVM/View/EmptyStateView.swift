//
//  EmptyStateView.swift
//  VEIL
//
//  Created by Ghady Al Omar on 06/12/1447 AH.
//

import SwiftUI

struct EmptyStateView: View {

    let pulseAnimation: Bool

    var body: some View {

        VStack(spacing: 0) {

            // MARK: - Animated Location Circles
            ZStack {

                Circle()
                    .fill(Color("OuterCircle3").opacity(0.5))
                    .frame(width: 93, height: 93)
                    .scaleEffect(pulseAnimation ? 1.06 : 1.0)
                    .animation(
                        .easeInOut(duration: 3)
                            .repeatForever(autoreverses: true),
                        value: pulseAnimation
                    )
                    .glassEffect()

                Circle()
                    .fill(Color("MiddleCircle3").opacity(0.7))
                    .frame(width: 70, height: 70)
                    .scaleEffect(pulseAnimation ? 1.04 : 1.0)
                    .animation(
                        .easeInOut(duration: 3)
                            .delay(0.3)
                            .repeatForever(autoreverses: true),
                        value: pulseAnimation
                    )
                    .glassEffect()
                    .overlay(
                        Image(systemName: "location")
                            .font(.system(size: 30))
                            .foregroundColor(Color("TitleColor").opacity(0.9))
                            .bold(true)
                    )
            }

            Spacer().frame(height: 16)

            Text("Set your place")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color("TitleColor"))

            Spacer().frame(height: 10)

            Text("Choose a location to begin your sensory journey.")
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(Color("SubtitleColor"))
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Spacer().frame(height: 32)
        }
    }
}

#Preview {
    ZStack {
        Color("BackgroundColor").ignoresSafeArea()
        EmptyStateView(pulseAnimation: true)
    }
}
