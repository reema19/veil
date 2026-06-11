//
//  BePresentView3.swift
//  VEIL
//
//  Created by Ghady Al Omar on 06/12/1447 AH.
//

import SwiftUI
import SwiftData

struct BePresentView3: View {
    private let page: OnboardingPage

    @Environment(\.modelContext) private var modelContext
    @ObservedObject private var viewModel: OnboardingViewModel

    init(page: OnboardingPage, viewModel: OnboardingViewModel) {
        self.page = page
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color("BackgroundColor").ignoresSafeArea()

            YellowCircleStackView(
                hideDots: viewModel.hideYellowDots,
                expandCircles: viewModel.expandYellowCircles
            )
            .offset(
                x: viewModel.expandYellowCircles ? 0 : 90,
                y: viewModel.expandYellowCircles ? 0 : 80
            )

            if viewModel.showNameField {
                NameEntryView(
                    name: $viewModel.enteredName,
                    onSubmit: {
                        viewModel.submitName(context: modelContext)
                    }
                )
                .transition(
                    .opacity.combined(with: .scale(scale: 0.96))
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else if !viewModel.hidePageThreeContent {
                VStack {
                    Spacer()

                    OnboardingTextBlock(
                        title: page.title,
                        subtitle: page.subtitle
                    )

                    Spacer().frame(height: 60)

                    StartButtonView(showCentered: false) {
                        viewModel.handleStart()
                    }
                    .frame(height: 50)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 22)
                }
                .transition(.opacity)
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    BePresentView3(
        page: OnboardingViewModel().pages[2],
        viewModel: OnboardingViewModel()
    )
    .modelContainer(for: [
        LocalProfile.self,
        Place.self,
        PlaceObservation.self
    ], inMemory: true)
}
