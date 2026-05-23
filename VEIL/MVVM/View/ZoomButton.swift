//
//  ZoomButton.swift
//  VEIL
//
//  Created by Ghady Al Omar on 07/12/1447 AH.
//

import SwiftUI

struct ZoomButton: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: isSelected ? 13 : 12, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? Color(red: 0.91, green: 0.78, blue: 0.25) : .white.opacity(0.75))
                .frame(width: isSelected ? 36 : 32, height: isSelected ? 36 : 32)
                .background(
                    Circle()
                        .fill(isSelected
                              ? Color(white: 0.31).opacity(0.85)
                              : Color(white: 0.39).opacity(0.55))
                )
        }
    }
}
