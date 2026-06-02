//
//  ShutterButton.swift
//  VEIL
//
//  Created by Ghady Al Omar on 07/12/1447 AH.
//
import SwiftUI

struct ShutterButton: View {
    let onCapture: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button {
            onCapture()
        } label: {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.94))
                    .frame(width: 86, height: 86)
                    .shadow(color: .black.opacity(0.16), radius: 8, x: 0, y: 5)

                Circle()
                    .stroke(Color.white.opacity(0.95), lineWidth: 5)
                    .frame(width: 74, height: 74)

                Circle()
                    .fill(Color.white)
                    .frame(width: 62, height: 62)
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.94 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}
