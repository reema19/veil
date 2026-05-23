//
//  BePresentView3.swift
//  VEIL
//
//  Created by Ghady Al Omar on 06/12/1447 AH.
//

import SwiftUI

struct BePresentView3: View {
    private let page: OnboardingPage

    @StateObject private var viewModel = OnboardingViewModel()

    init(page: OnboardingPage) {
        self.page = page
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color("BackgroundColor").ignoresSafeArea()

            ZStack {
                Image(page.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 360, height: 400)
                    .offset(x: 70, y: 0)
                    .scaleEffect(viewModel.isAnimating ? 1.06 : 1.0)
                    .offset(y: viewModel.isAnimating ? -8 : 0)
                    .animation(
                        .easeInOut(duration: 3)
                            .repeatForever(autoreverses: true),
                        value: viewModel.isAnimating
                    )
            }
            .offset(x: 30, y: 40)

            VStack {
                Spacer()

                OnboardingTextBlock(
                    title: page.title,
                    subtitle: page.subtitle
                )

                Spacer().frame(height: 120)

                StartButtonView(showCentered: viewModel.showStartCentered) {
                    viewModel.handleStart()
                }
                .frame(height: 44)
                .padding(.horizontal, 32)
                .padding(.bottom, 36)
                .animation(
                    .spring(response: 0.6, dampingFraction: 0.75),
                    value: viewModel.showStartCentered
                )
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.startAnimations()
        }
        .navigationDestination(isPresented: $viewModel.goToMainpage) {
            Mainpage()
                .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    NavigationStack {
        BePresentView3(page: OnboardingViewModel().pages[2])
    }
}
