//
//  AIHaloView.swift
//  VEIL
//
//  Created by reema aljohani on 5/25/26.

import SwiftUI

struct AIHaloView: View {

    @State private var breathe = false
    @State private var drift = false
    @State private var rotate = false
    @State private var pulse = false

    var size: CGFloat = 360
    var expanded: Bool = false
    var sense: SenseType = .sight

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

            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            .white.opacity(expanded ? 0.30 : 0.78),
                            Color(hex: "D8DFE9").opacity(expanded ? 0.26 : 0.72),
                            Color(hex: "CFDECA").opacity(expanded ? 0.22 : 0.54),
                            accentColor.opacity(expanded ? 0.34 : 0.16),
                            .clear
                        ],
                        center: .center,
                        startRadius: size * 0.03,
                        endRadius: size * 0.46
                    )
                )
                .frame(
                    width: size * (expanded ? 2.8 : 0.90),
                    height: size * (expanded ? 2.9 : 0.78)
                )
                .blur(radius: size * (expanded ? 0.18 : 0.10))
                .scaleEffect(breathe ? 1.05 : 0.96)

            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "EFF0A3").opacity(expanded ? 0.30 : 0.58),
                            Color(hex: "EFF0A3").opacity(expanded ? 0.12 : 0.16),
                            .clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: size * 0.72, height: size * 0.36)
                .blur(radius: size * 0.08)
                .offset(y: drift ? -size * 0.18 : -size * 0.10)

            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [
                            .clear,
                            Color(hex: "D8DFE9").opacity(expanded ? 0.28 : 0.62),
                            Color(hex: "D8DFE9").opacity(expanded ? 0.34 : 0.84)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: size * 0.76, height: size * 0.42)
                .blur(radius: size * 0.08)
                .offset(y: drift ? size * 0.20 : size * 0.12)

            SoftSignals(size: size, animate: pulse)
                .opacity(expanded ? 0.25 : 0.70)
        }
        .frame(width: size, height: size)
        .scaleEffect(expanded ? 2.4 : 1)
        .rotationEffect(.degrees(rotate ? 360 : 0))
        .animation(.easeInOut(duration: 0.65), value: expanded)
        .onAppear {
            withAnimation(.easeInOut(duration: 4.8).repeatForever(autoreverses: true)) {
                breathe = true
            }

            withAnimation(.easeInOut(duration: 5.6).repeatForever(autoreverses: true)) {
                drift = true
            }

            withAnimation(.linear(duration: 26).repeatForever(autoreverses: false)) {
                rotate = true
            }

            withAnimation(.easeInOut(duration: 3.8).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}

private struct SoftSignals: View {

    let size: CGFloat
    let animate: Bool

    private let signals: [(x: CGFloat, y: CGFloat, dotSize: CGFloat, color: String)] = [
        (0.34, 0.28, 2.4, "EFF0A3"),
        (0.66, 0.30, 2.2, "CFDECA"),
        (0.27, 0.58, 2.0, "D8DFE9"),
        (0.72, 0.62, 2.2, "EFF0A3"),
        (0.44, 0.78, 2.0, "CFDECA"),
        (0.58, 0.80, 2.0, "D8DFE9")
    ]

    var body: some View {
        ZStack {
            ForEach(Array(signals.enumerated()), id: \.offset) { index, signal in
                Circle()
                    .fill(Color(hex: signal.color).opacity(0.65))
                    .frame(
                        width: signal.dotSize * (size / 360),
                        height: signal.dotSize * (size / 360)
                    )
                    .position(
                        x: signal.x * size,
                        y: signal.y * size
                    )
                    .offset(
                        x: animate ? CGFloat(index % 2 == 0 ? 5 : -5) : 0,
                        y: animate ? CGFloat(index % 2 == 0 ? -5 : 5) : 0
                    )
                    .scaleEffect(animate ? 1.16 : 0.84)
                    .opacity(animate ? 0.75 : 0.30)
            }
        }
        .frame(width: size, height: size)
    }
}
#Preview {
    ZStack {
        Color("BackgroundColor").ignoresSafeArea()
        AIHaloView(size: 320)
    }
}

