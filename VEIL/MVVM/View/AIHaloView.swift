//
//  AIHaloView.swift
//  VEIL
//
//  Created by reema aljohani on 5/25/26.

import SwiftUI

struct AIHaloView: View {

    @State private var yellowX: CGFloat = -10
    @State private var blueX: CGFloat = 10
    @State private var greenX: CGFloat = -6

    var size: CGFloat = 360
    var expanded: Bool = false
    var sense: SenseType = .sight
    var isThinking: Bool = false

    private var accentColor: Color {
        switch sense {
        case .sight:
            return Color(hex: "EFF0A3")
        case .sound:
            return Color(hex: "D8DFE9")
        }
    }

    var body: some View {

        ZStack {

            // Base Glow

            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            .white.opacity(0.92),
                            Color(hex: "D8DFE9").opacity(0.82),
                            Color(hex: "CFDECA").opacity(0.72),
                            accentColor.opacity(0.45),
                            .clear
                        ],
                        center: .center,
                        startRadius: size * 0.04,
                        endRadius: size * 0.48
                    )
                )
                .frame(
                    width: size * 0.95,
                    height: size * 0.82
                )
                .blur(radius: size * 0.12)

            // Yellow Layer

            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "EFF0A3").opacity(0.95),
                            Color(hex: "EFF0A3").opacity(0.55),
                            .clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(
                    width: size * 0.82,
                    height: size * 0.42
                )
                .blur(radius: size * 0.14)
                .offset(
                    x: isThinking ? yellowX : 0,
                    y: -size * 0.10
                )

            // Blue Layer

            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [
                            .clear,
                            Color(hex: "D8DFE9").opacity(0.88),
                            Color(hex: "D8DFE9").opacity(1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(
                    width: size * 0.88,
                    height: size * 0.48
                )
                .blur(radius: size * 0.14)
                .offset(
                    x: isThinking ? blueX : 0,
                    y: size * 0.12
                )

            // Green Layer

            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "CFDECA").opacity(0.72),
                            .clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: size * 0.34
                    )
                )
                .frame(
                    width: size * 0.66,
                    height: size * 0.66
                )
                .blur(radius: size * 0.16)
                .offset(
                    x: isThinking ? greenX : 0,
                    y: size * 0.02
                )

            SoftSignals(
                size: size,
                animate: isThinking
            )
        }
        .frame(width: size, height: size)
        .scaleEffect(expanded ? 2.4 : 1)
        .onAppear {

            guard isThinking else { return }

            withAnimation(
                .easeInOut(duration: 2.0)
                .repeatForever(autoreverses: true)
            ) {
                yellowX = 14
            }

            withAnimation(
                .easeInOut(duration: 2.4)
                .repeatForever(autoreverses: true)
            ) {
                blueX = -14
            }

            withAnimation(
                .easeInOut(duration: 2.8)
                .repeatForever(autoreverses: true)
            ) {
                greenX = 10
            }
        }
    }
}

private struct SoftSignals: View {

    let size: CGFloat
    let animate: Bool

    private let signals: [(x: CGFloat, y: CGFloat, dotSize: CGFloat, color: String)] = [
        (0.34, 0.28, 2.5, "EFF0A3"),
        (0.66, 0.30, 2.2, "CFDECA"),
        (0.27, 0.58, 2.0, "D8DFE9"),
        (0.72, 0.62, 2.4, "EFF0A3"),
        (0.44, 0.78, 2.0, "CFDECA"),
        (0.58, 0.80, 2.0, "D8DFE9")
    ]

    var body: some View {

        ZStack {

            ForEach(Array(signals.enumerated()), id: \.offset) { index, signal in

                Circle()
                    .fill(Color(hex: signal.color))
                    .frame(
                        width: signal.dotSize * (size / 360),
                        height: signal.dotSize * (size / 360)
                    )
                    .position(
                        x: signal.x * size,
                        y: signal.y * size
                    )
                    .offset(
                        x: animate ? CGFloat(index % 2 == 0 ? 4 : -4) : 0,
                        y: animate ? CGFloat(index % 2 == 0 ? -4 : 4) : 0
                    )
                    .opacity(animate ? 0.9 : 0.45)
            }
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    ZStack {
        Color("BackgroundColor").ignoresSafeArea()

        AIHaloView(
            size: 320,
            isThinking: true
        )
    }
}
