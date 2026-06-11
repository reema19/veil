//
//  LocationPermissionSheetView.swift
//  VEIL
//

import SwiftUI

struct LocationPermissionSheetView: View {

    let onClose: () -> Void
    let onDone: () -> Void

    var body: some View {
        GeometryReader { geometry in
            let sheetWidth = geometry.size.width
            let scale = sheetWidth / 393
            let sheetHeight = 500 * scale

            ZStack(alignment: .bottom) {

                Color.black.opacity(0.18)
                    .ignoresSafeArea()
                    .transition(.opacity)

                ZStack(alignment: .topLeading) {

                    LocationPermissionSheetShape()
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
                        Image("xmarkVector")
                            .resizable()
                            .scaledToFit()
                            .frame(
                                width: 102 * scale,
                                height: 102 * scale
                            )
                            .blur(radius: 2)

                        Image(systemName: "location.viewfinder")
                            .font(.system(size: 28 * scale, weight: .medium))
                            .foregroundColor(Color("TitleColor"))
                    }
                    .position(
                        x: sheetWidth * 0.5,
                        y: sheetHeight * 0.326
                    )

                    Text("We notice you through place")
                        .font(.custom("DMSans-Bold", size: min(24 * scale, 24)))
                        .foregroundColor(Color("TitleColor"))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                        .frame(width: sheetWidth * 0.82)
                        .position(
                            x: sheetWidth * 0.5,
                            y: sheetHeight * 0.475
                        )

                    Text("Sense uses your location only when you arrive at a place you saved.")
                        .font(.custom("DMSans-Regular", size: min(16 * scale, 16)))
                        .foregroundColor(Color("SubtitleColor"))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(width: sheetWidth * 0.82)
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
                .transition(.move(edge: .bottom))
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }
}

struct LocationPermissionSheetShape: Shape {
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

        LocationPermissionSheetView(
            onClose: {},
            onDone: {}
        )
    }
}
