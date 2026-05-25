//
//  BlueCircleStackView.swift
//  VEIL
//
//  Created by Rahaf Alhammadi on 07/12/1447 AH.
//

import SwiftUI

struct BlueCircleStackView: View {

    @State private var rotateDots = false

    var body: some View {
        ZStack {
            Image("LargeBlueCircle")
                .resizable()
                .scaledToFit()
                .frame(width: 388, height: 500)
                .offset(x: -10, y: -10)

            Image("MiddleBlueCircle")
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 350)
                .offset(x: 30, y: -20)

            Image("SmallBlueCircle")
                .resizable()
                .scaledToFit()
                .frame(width: 190, height: 190)
                .offset(x: 45, y: -20)

            Image("BlueDotsCircle")
                .resizable()
                .scaledToFit()
                .frame(width: 180, height: 180)
                .rotationEffect(.degrees(rotateDots ? 360 : 300.0))
                .offset(x: 45, y: -23)
                .animation(
                    .linear(duration: 8)
                    .repeatForever(autoreverses: false),
                    value: rotateDots
                )
        }
        .frame(width: 360, height: 350)
        .onAppear {
            rotateDots = true
        }
    }
}

#Preview {
    ZStack {
        Color("BackgroundColor")
            .ignoresSafeArea()

        BlueCircleStackView()
            .offset(x: 45, y: -40)
    }
}
