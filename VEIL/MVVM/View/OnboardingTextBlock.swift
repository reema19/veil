
//  OnboardingTextBlock.swift
//  VEIL
//

import SwiftUI

struct OnboardingTextBlock: View {
    let title: String
    let subtitle: String

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var isAccessibilitySize: Bool {
        dynamicTypeSize.isAccessibilitySize
    }

    private var textSpacing: CGFloat {
        isAccessibilitySize ? 16 : 10
    }

    private var horizontalPadding: CGFloat {
        isAccessibilitySize ? 28 : 32
    }

    var body: some View {
        VStack(alignment: .leading, spacing: textSpacing) {
            Text(title)
                .font(.veilHero)
                .foregroundColor(Color("TitleColor"))
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)

            Text(subtitle)
                .font(.veilBody)
                .italic()
                .foregroundColor(Color("SubtitleColor"))
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, horizontalPadding)
    }
}
