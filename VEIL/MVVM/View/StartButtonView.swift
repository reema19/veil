import SwiftUI

struct StartButtonView: View {
    let showCentered: Bool
    let action: () -> Void

    @State private var dashPhase: CGFloat = 0

    var body: some View {
        ZStack {
            if !showCentered {
                ZStack {
                    DotsIndicatorView(totalPages: 3, currentIndex: 2)
                        .frame(maxWidth: .infinity, alignment: .center)

                    HStack {
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
                                            lineCap: .round,
                                            dash: [4, 6],
                                            dashPhase: dashPhase
                                        )
                                    )
                                    .foregroundColor(Color("DashColor"))
                            )
                    }
                }
                .transition(.opacity)
                .onAppear {
                    dashPhase = 0

                    withAnimation(
                        .linear(duration: 1.8)
                        .repeatForever(autoreverses: false)
                    ) {
                        dashPhase = -20
                    }
                }
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
                            insertion: .opacity.combined(with: .scale(scale: 0.92)),
                            removal: .opacity
                        )
                    )
            }
        }
    }
}
