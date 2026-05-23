//
//  MainTabBar.swift
//  VEIL
//
//  Created by Ghady Al Omar on 06/12/1447 AH.
//
//
//  MainTabBar.swift
//  ghady
//

import SwiftUI

struct MainTabBar: View {
    @Binding var selectedTab: Int

    var body: some View {
        HStack(spacing: 10) {
            HStack(spacing: 0) {
                TabBarButton(
                    icon: "house.fill",
                    label: "Main",
                    isSelected: selectedTab == 0
                ) { selectedTab = 0 }

                TabBarButton(
                    icon: "archivebox",
                    label: "Memory",
                    isSelected: selectedTab == 1
                ) { selectedTab = 1 }
            }
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(Color("TitleColor").opacity(0.08), lineWidth: 1)
            )

            Button(action: { selectedTab = 2 }) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 25))
                    .foregroundColor(
                        selectedTab == 2 ? Color("TitleColor") : Color("SubtitleColor")
                    )
                    .frame(width: 58, height: 58)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .strokeBorder(Color("TitleColor").opacity(0.08), lineWidth: 1)
                    )
            }
        }
    }
}
