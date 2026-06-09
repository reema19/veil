//
//  MainTabBar.swift
//  VEIL
//

import SwiftUI

struct MainTabBar: View {
    @Binding var selectedTab: Int

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var isAccessibilitySize: Bool {
        dynamicTypeSize.isAccessibilitySize
    }

    var body: some View {
        HStack(spacing: 0) {
            TabBarButton(
                icon: "house.fill",
                label: "Main",
                isSelected: selectedTab == 0
            ) {
                selectedTab = 0
            }

            TabBarButton(
                icon: "archivebox",
                label: "Memory",
                isSelected: selectedTab == 1
            ) {
                selectedTab = 1
            }
        }
        .padding(isAccessibilitySize ? 6 : 0)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .strokeBorder(Color("TitleColor").opacity(0.08), lineWidth: 1)
        )
    }
}
