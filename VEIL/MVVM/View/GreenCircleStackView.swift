//
//  GreenCircleStackView.swift
//  VEIL
//
//  Created by Rahaf Alhammadi on 07/12/1447 AH.


import SwiftUI

struct GreenCircleStackView: View {

    @State private var rotateDots = false

    var body: some View {
        ZStack {
            Image("LargeGreenCircle")
                .resizable()
                .scaledToFit()
                .frame(width: 310, height: 500)
                .offset(x: -25, y: -10)

            Image("MiddleGreenCircle")
                .resizable()
                .scaledToFit()
                .frame(width: 270, height: 350)
                .offset(x: -6, y: 0)

            Image("SmallGreenCircle")
                .resizable()
                .scaledToFit()
                .frame(width: 190, height: 190)
                .offset(x: -6, y: 0)

            Image("GreenDotsCircle")
                .resizable()
                .scaledToFit()
                .frame(width: 180, height: 180)
                .rotationEffect(.degrees(rotateDots ? 360 : 300))
                .offset(x: -6, y: -3)
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

        GreenCircleStackView()
            .offset(x: 70, y: -20)
    }
}
