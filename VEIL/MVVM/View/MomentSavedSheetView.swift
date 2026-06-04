//
//  MomentSavedSheetView.swift
//  VEIL
//
//  Created by reema aljohani on 6/3/26.
//
//
//  MomentSavedSheetView.swift
//  VEIL
//

import SwiftUI

struct MomentSavedSheetView: View {
    let onClose: () -> Void
    let onDone: () -> Void

    var body: some View {
        GeometryReader { geometry in
            let sheetWidth = geometry.size.width
            let scale = sheetWidth / 393
            let sheetHeight = 500 * scale

            ZStack(alignment: .bottom) {
                Color.clear
                    .ignoresSafeArea()

                ZStack(alignment: .topLeading) {

                    MomentSavedSheetShape()
                        .fill(Color.white)
                        .frame(width: sheetWidth, height: sheetHeight)

                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 17 * scale, weight: .medium))
                            .foregroundColor(Color(hex: "727272"))
                            .frame(width: 44 * scale, height: 44 * scale)
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                    .position(
                        x: sheetWidth * 0.501,
                        y: sheetHeight * 0.058
                    )

                    ZStack {
                        SmallSavedHalo()
                            .frame(
                                width: 108 * scale,
                                height: 108 * scale
                            )

                        Image(systemName: "checkmark")
                            .font(.system(size: 40 * scale, weight: .semibold))
                            .foregroundColor(Color(hex: "111111"))
                    }
                    .position(
                        x: sheetWidth * 0.5,
                        y: sheetHeight * 0.326
                    )

                    Text("Moment saved")
                        .font(.custom("DMSans-Medium", size: min(32 * scale, 32)))
                        .foregroundColor(Color(hex: "212121"))
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .frame(width: sheetWidth * 0.82)
                        .position(
                            x: sheetWidth * 0.5,
                            y: sheetHeight * 0.475
                        )

                    Text("This moment is now part of your place.\nCome back tomorrow for another.")
                        .font(.custom("DMSans-Regular", size: min(17 * scale, 17)))
                        .foregroundColor(Color(hex: "444444"))
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(width: sheetWidth * 0.86)
                        .position(
                            x: sheetWidth * 0.5,
                            y: sheetHeight * 0.60
                        )

                    Button(action: onDone) {
                        Text("Done")
                            .font(.custom("DMSans-Bold", size: min(15 * scale, 15)))
                            .foregroundColor(.white)
                            .frame(
                                width: sheetWidth * 0.8564,
                                height: sheetHeight * 0.124
                            )
                            .background(Color(hex: "1F1F1F"))
                            .clipShape(Capsule())
                    }
                    .position(
                        x: sheetWidth * 0.5,
                        y: sheetHeight * 0.862
                    )
                }
                .frame(width: sheetWidth, height: sheetHeight)
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }
}

struct MomentSavedSheetShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let sx = rect.width / 393
        let sy = rect.height / 500

        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: x * sx, y: y * sy)
        }

        path.move(to: p(0, 110))

        path.addCurve(
            to: p(62.4769, 48),
            control1: p(0, 76),
            control2: p(28.2154, 48)
        )

        path.addLine(to: p(149.138, 48))

        path.addCurve(
            to: p(183.4, 63.5),
            control1: p(163.246, 48),
            control2: p(173.323, 54.5)
        )

        path.addCurve(
            to: p(210.104, 63.5),
            control1: p(190.454, 69.5),
            control2: p(203.05, 69.5)
        )

        path.addCurve(
            to: p(243.862, 48),
            control1: p(220.181, 54.5),
            control2: p(229.754, 48)
        )

        path.addLine(to: p(330.523, 48))

        path.addCurve(
            to: p(393, 110),
            control1: p(364.785, 48),
            control2: p(393, 76)
        )

        path.addLine(to: p(393, 500))
        path.addLine(to: p(0, 500))
        path.closeSubpath()

        return path
    }
}

struct SmallSavedHalo: View {
    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    stops: [
                        .init(color: Color(hex: "EFF0A3").opacity(0.85), location: 0.0),
                        .init(color: Color(hex: "CFDECA").opacity(0.55), location: 0.42),
                        .init(color: Color(hex: "D8DFE9").opacity(0.38), location: 0.76),
                        .init(color: Color.white.opacity(0), location: 1.0)
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: 54
                )
            )
    }
}

#Preview {
    ZStack {
        Color(hex: "F4F4E8")
            .ignoresSafeArea()

        VStack {
            Spacer()

            RoundedRectangle(cornerRadius: 42)
                .fill(Color.gray.opacity(0.22))
                .frame(width: 330, height: 330)
                .padding(.bottom, 120)
        }

        MomentSavedSheetView(
            onClose: {},
            onDone: {}
        )
    }
}
