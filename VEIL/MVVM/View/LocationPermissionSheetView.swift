//
//  LocationPermissionSheetView.swift
//  VEIL
//

import SwiftUI

struct LocationPermissionSheetView: View {

    let onClose: () -> Void
    let onDone: () -> Void

    var body: some View {

        ZStack {

            // dark background
            Color.black.opacity(0.18)
                .ignoresSafeArea()
                .transition(.opacity)

            VStack {

                Spacer()

                VStack(spacing: 0) {

                    // top button
                    ZStack {
                        Button(action: onClose) {
                            Image(systemName: "xmark")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.gray)
                                .frame(width: 56, height: 56)
                                .background(Color.white)
                                .clipShape(Circle())
                        }
                        .offset(y: -28)
                    }

                    Spacer().frame(height: 4)

                    // icon
                    ZStack {

                        Image("xmarkVector")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 102, height: 102)
                            .blur(radius: 2)

                        Image(systemName: "location.viewfinder")
                            .font(.system(size: 28, weight: .medium))
                            .foregroundColor(Color("TitleColor"))
                    }

                    Spacer().frame(height: 34)

                    Text("We notice you through place")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color("TitleColor"))
                        .multilineTextAlignment(.center)

                    Spacer().frame(height: 14)

                    Text("Sense uses your location only when you arrive at a place you saved.")
                        .font(.system(size: 16))
                        .foregroundColor(Color("SubtitleColor"))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 32)

                    Spacer()

                    // done button
                    Button(action: onDone) {
                        Text("Done")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: 366)
                            .frame(height: 62)
                            .background(Color.black)
                            .clipShape(Capsule())
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 36)
                }
                .frame(height: 450)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 70)
                        .fill(Color.white)
                )
                .transition(.move(edge: .bottom))
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }
}

#Preview {
    LocationPermissionSheetView(
        onClose: {},
        onDone: {}
    )
}
