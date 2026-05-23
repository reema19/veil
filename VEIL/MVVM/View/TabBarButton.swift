//
//  TabBarButton.swift
//  VEIL
//
//  Created by Ghady Al Omar on 06/12/1447 AH.
//

//
//  TabBarButton.swift
//  ghady
//

import SwiftUI

struct TabBarButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(label)
                    .font(.system(size: 11, weight: .medium))
            }
            .foregroundColor(isSelected ? Color("TitleColor") : Color("SubtitleColor"))
            .frame(width: 100, height: 58)
            .background(
                isSelected
                    ? Color("TitleColor").opacity(0.08)
                    : Color.clear
            )
            .clipShape(Capsule())
        }
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}
