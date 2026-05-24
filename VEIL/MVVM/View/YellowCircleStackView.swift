//
//  YellowCircleStackView.swift
//  VEIL
//

import SwiftUI

struct YellowCircleStackView: View {

    @State private var rotateDots = false

    var body: some View {
        ZStack {
            Image("LargeYellowCircle")
                .resizable()
                .scaledToFit()
                .frame(width: 290, height: 500)
                .offset(x: -15, y: -10)

            Image("MiddleYellowCircle")
                .resizable()
                .scaledToFit()
                .frame(width: 240, height: 350)
                .offset(x: -5, y: 10)

            Image("SmallYellowCircle")
                .resizable()
                .scaledToFit()
                .frame(width: 190, height: 190)
                .offset(x: 6, y: 10)

            Image("YellowDotsCircle")
                .resizable()
                .scaledToFit()
                .frame(width: 180, height: 180)
                .rotationEffect(.degrees(rotateDots ? 360 : 300))
                .offset(x: 6, y: 8)
                .animation(
                    .linear(duration: 8)
                        .repeatForever(autoreverses: false),
                    value: rotateDots
                )
        }
        .frame(width: 360, height: 400)
        .onAppear {
            rotateDots = true
        }
    }
}

#Preview {
    ZStack {
        Color("BackgroundColor")
            .ignoresSafeArea()

        YellowCircleStackView()
            .offset(x: 100, y: 40)
    }
}
