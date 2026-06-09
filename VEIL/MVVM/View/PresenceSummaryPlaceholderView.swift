//
//  PresenceSummaryPlaceholderView.swift
//  VEIL
//

import SwiftUI

struct PresenceSummaryPlaceholderView: View {

    let totalTime: String

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var isAccessibilitySize: Bool {
        dynamicTypeSize.isAccessibilitySize
    }

    private var haloSize: CGFloat {
        isAccessibilitySize ? 320 : 270
    }

    private var containerHeight: CGFloat {
        isAccessibilitySize ? 340 : 290
    }

    var body: some View {

        ZStack {

            PresenceBreathRing(size: haloSize)

            VStack(spacing: isAccessibilitySize ? 8 : 4) {

                Text("total")
                    .font(
                        .custom(
                            "DMSans-Regular",
                            size: 13,
                            relativeTo: .caption
                        )
                    )
                    .foregroundColor(Color("SubtitleColor"))
                    .lineLimit(1)

                Text(totalTime)
                    .font(
                        .custom(
                            "DMSans-Bold",
                            size: 22,
                            relativeTo: .title2
                        )
                    )
                    .foregroundColor(Color("TitleColor"))
                    .minimumScaleFactor(0.8)
                    .multilineTextAlignment(.center)

                Text("time present")
                    .font(
                        .custom(
                            "DMSans-Regular",
                            size: 12,
                            relativeTo: .caption
                        )
                    )
                    .foregroundColor(Color("SubtitleColor"))
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 24)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Total presence time \(totalTime)")
        }
        .frame(maxWidth: .infinity)
        .frame(height: containerHeight)
    }
}
