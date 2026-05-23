//
//  StartButtonView.swift
//  VEIL
//
//  Created by Ghady Al Omar on 06/12/1447 AH.
//

import SwiftUI

struct StartButtonView: View {
    let showCentered: Bool
    let action: () -> Void

    var body: some View {
        ZStack {
            if !showCentered {
                HStack {
                    DotsIndicatorView(totalPages: 3, currentIndex: 2)

                    Spacer()

                    Button("Start", action: action)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color("TitleColor"))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .strokeBorder(
                                    style: StrokeStyle(
                                        lineWidth: 1.5,
                                        dash: [4, 6]
                                    )
                                )
                                .foregroundColor(Color("DashColor"))
                        )
                }
                .transition(.opacity)
            }

            if showCentered {
                Button("Start", action: action)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(Color(hex: "#F8F8F8"))
                    .kerning(-0.43)
                    .frame(width: 160, height: 50)
                    .background(
                        Capsule()
                            .fill(Color(hex: "#212121"))
                    )
                    .transition(
                        .asymmetric(
                            insertion: .opacity.combined(
                                with: .scale(scale: 0.92)
                            ),
                            removal: .opacity
                        )
                    )
            }
        }
    }
}
