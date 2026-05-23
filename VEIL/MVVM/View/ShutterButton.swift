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
        Button { onCapture() } label: {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.9))
                    .frame(width: 78, height: 78)
                Circle()
                    .fill(Color.white.opacity(0.95))
                    .shadow(color: .black.opacity(0.12), radius: 3, x: 0, y: 1)
                    .frame(width: 64, height: 64)
            }
        }
        .scaleEffect(isPressed ? 0.94 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded   { _ in isPressed = false }
        )
    }
}
