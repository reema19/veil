//
//  PresenceBreathRing.swift
//  VEIL
//
//  Created by reema aljohani on 5/25/26.
//


import SwiftUI

struct PresenceBreathRing: View {

    @State private var breathe = false
    @State private var rotateOuter = false
    @State private var rotateInner = false
    @State private var shimmer = false

    var size: CGFloat = 240

    var body: some View {

        ZStack {

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "EFF0A3").opacity(0.42),
                            Color(hex: "CFDECA").opacity(0.28),
                            Color(hex: "D8DFE9").opacity(0.20),
                            .clear
                        ],
                        center: .center,
                        startRadius: 6,
                        endRadius: size * 0.62
                    )
                )
                .frame(width: size * 1.04, height: size * 1.04)
                .blur(radius: size * 0.065)
                .scaleEffect(breathe ? 1.055 : 0.985)
                .opacity(breathe ? 0.96 : 0.76)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "EFF0A3").opacity(0.22),
                            Color(hex: "CFDECA").opacity(0.12),
                            .clear
                        ],
                        center: .center,
                        startRadius: 1,
                        endRadius: size * 0.28
                    )
                )
                .frame(width: size * 0.52, height: size * 0.52)
                .blur(radius: 10)
                .scaleEffect(breathe ? 1.06 : 0.97)
                .opacity(0.82)

            Circle()
                .stroke(
                    Color(hex: "DCD96B").opacity(0.58),
                    style: StrokeStyle(
                        lineWidth: 1.45,
                        lineCap: .round,
                        dash: [3, 12]
                    )
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(rotateOuter ? 360 : 0))

            Circle()
                .stroke(
                    Color(hex: "B9C6D8").opacity(0.58),
                    style: StrokeStyle(
                        lineWidth: 1.45,
                        lineCap: .round,
                        dash: [3, 11]
                    )
                )
                .frame(width: size * 0.48, height: size * 0.48)
                .rotationEffect(.degrees(rotateInner ? -360 : 0))

            Circle()
                .stroke(
                    Color(hex: "C7D8C5").opacity(0.34),
                    style: StrokeStyle(
                        lineWidth: 1.1,
                        lineCap: .round,
                        dash: [2, 16]
                    )
                )
                .frame(width: size * 0.74, height: size * 0.74)
                .rotationEffect(.degrees(rotateInner ? 360 : 0))

            HaloOrbitDots(
                size: size,
                shimmer: shimmer,
                rotateOuter: rotateOuter,
                rotateInner: rotateInner
            )
        }
        .frame(width: size, height: size)
        .drawingGroup()
        .onAppear {

            withAnimation(.easeInOut(duration: 7).repeatForever(autoreverses: true)) {
                breathe = true
            }

            withAnimation(.linear(duration: 38).repeatForever(autoreverses: false)) {
                rotateOuter = true
            }

            withAnimation(.linear(duration: 38).repeatForever(autoreverses: false)) {
                rotateInner = true
            }

            withAnimation(.easeInOut(duration: 5.2).repeatForever(autoreverses: true)) {
                shimmer = true
            }
        }
    }
}

private struct HaloOrbitDots: View {

    let size: CGFloat
    let shimmer: Bool
    let rotateOuter: Bool
    let rotateInner: Bool

    private let outerDots: [(angle: Double, dotSize: CGFloat, color: String, opacity: Double)] = [
        (-158, 5.0, "D8DFE9", 0.58),
        (-130, 4.0, "CFDECA", 0.56),
        (-100, 5.6, "EFF0A3", 0.66),
        (-64, 4.0, "D8DFE9", 0.54),
        (-28, 5.4, "EFF0A3", 0.64),
        (2, 4.0, "CFDECA", 0.54),
        (42, 5.4, "D8DFE9", 0.56),
        (84, 4.1, "CFDECA", 0.54),
        (124, 6.0, "EFF0A3", 0.68),
        (154, 4.3, "CFDECA", 0.56)
    ]

    private let innerDots: [(angle: Double, dotSize: CGFloat, color: String, opacity: Double)] = [
        (-145, 3.1, "CFDECA", 0.42),
        (-110, 3.5, "D8DFE9", 0.40),
        (-78, 3.0, "EFF0A3", 0.46),
        (-34, 3.5, "CFDECA", 0.42),
        (8, 3.0, "D8DFE9", 0.40),
        (56, 3.5, "EFF0A3", 0.46),
        (102, 3.0, "CFDECA", 0.42),
        (144, 3.5, "D8DFE9", 0.40)
    ]

    var body: some View {
        ZStack {
            orbitDots(dots: outerDots, radius: size * 0.50)
                .rotationEffect(.degrees(rotateOuter ? 360 : 0))

            orbitDots(dots: innerDots, radius: size * 0.37)
                .rotationEffect(.degrees(rotateInner ? -360 : 0))
        }
        .frame(width: size, height: size)
    }

    private func orbitDots(
        dots: [(angle: Double, dotSize: CGFloat, color: String, opacity: Double)],
        radius: CGFloat
    ) -> some View {
        ZStack {
            ForEach(Array(dots.enumerated()), id: \.offset) { _, dot in
                Circle()
                    .fill(Color(hex: dot.color))
                    .frame(
                        width: dot.dotSize * (size / 240),
                        height: dot.dotSize * (size / 240)
                    )
                    .opacity(shimmer ? dot.opacity : dot.opacity * 0.78)
                    .scaleEffect(shimmer ? 1.08 : 0.96)
                    .shadow(
                        color: Color(hex: dot.color).opacity(0.16),
                        radius: shimmer ? 4 : 2
                    )
                    .offset(
                        x: cos(dot.angle * .pi / 180) * radius,
                        y: sin(dot.angle * .pi / 180) * radius
                    )
            }
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    PresenceBreathRing()
}
