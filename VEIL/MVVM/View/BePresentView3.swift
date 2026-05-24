//
//  BePresentView3.swift
//  VEIL
//
//  Created by Ghady Al Omar on 06/12/1447 AH.
//

import SwiftUI

struct BePresentView3: View {
    private let page: OnboardingPage

    @ObservedObject private var viewModel: OnboardingViewModel

    init(page: OnboardingPage, viewModel: OnboardingViewModel) {
        self.page = page
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color("BackgroundColor").ignoresSafeArea()

            YellowCircleStackView()
                .offset(x: 90, y: 130)

            VStack {
                Spacer()

                OnboardingTextBlock(
                    title: page.title,
                    subtitle: page.subtitle
                )

                Spacer().frame(height: 60)

                StartButtonView {
                    viewModel.handleStart()
                }
                .frame(height: 50)
                .padding(.horizontal, 32)
                .padding(.bottom, 36)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.startAnimations()
        }
    }
}

#Preview {
    BePresentView3(
        page: OnboardingViewModel().pages[2],
        viewModel: OnboardingViewModel()
    )
}
