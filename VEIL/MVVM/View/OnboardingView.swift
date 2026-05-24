//
//  OnboardingView.swift
//  VEIL
//
//  Created by Ghady Al Omar on 06/12/1447 AH.
//

import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundColor")
                    .ignoresSafeArea()

                currentOnboardingPage
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(
                        .asymmetric(
                            insertion: .opacity,
                            removal: .opacity
                        )
                    )
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $viewModel.goToMainpage) {
                Mainpage()
                    .navigationBarBackButtonHidden(true)
            }
        }
    }

    @ViewBuilder
    private var currentOnboardingPage: some View {
        switch viewModel.currentIndex {
        case 0:
            BePresentView(
                page: viewModel.pages[0],
                onNext: {
                    viewModel.goToNextPage()
                }
            )
            .id(0)

        case 1:
            BePresentView2(
                page: viewModel.pages[1],
                onNext: {
                    viewModel.goToNextPage()
                }
            )
            .id(1)

        case 2:
            BePresentView3(
                page: viewModel.pages[2],
                viewModel: viewModel
            )
            .id(2)

        default:
            EmptyView()
        }
    }
}

// MARK: - Previews

#Preview {
    OnboardingView()
}

#Preview {
    BePresentView(
        page: OnboardingViewModel().pages[0],
        onNext: {}
    )
}

#Preview {
    BePresentView2(
        page: OnboardingViewModel().pages[1],
        onNext: {}
    )
}

#Preview {
    BePresentView3(
        page: OnboardingViewModel().pages[2],
        viewModel: OnboardingViewModel()
    )
}
