//
//  TabBarButton.swift
//  VEIL
//

import SwiftUI

struct TabBarButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var isAccessibilitySize: Bool {
        dynamicTypeSize.isAccessibilitySize
    }

    private var buttonWidth: CGFloat {
        isAccessibilitySize ? 112 : 100
    }

    private var buttonHeight: CGFloat {
        isAccessibilitySize ? 68 : 58
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: isAccessibilitySize ? 6 : 4) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .accessibilityHidden(true)

                Text(label)
                    .font(.custom("DMSans-Medium", size: 11, relativeTo: .caption))
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            .foregroundColor(isSelected ? Color("TitleColor") : Color("SubtitleColor"))
            .frame(width: buttonWidth, height: buttonHeight)
            .background(
                isSelected
                    ? Color("TitleColor").opacity(0.08)
                    : Color.clear
            )
            .clipShape(Capsule())
        }
        .accessibilityLabel(label)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}
