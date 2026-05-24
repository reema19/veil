//
//  BePresentView.swift
//  VEIL
//
//  Created by Ghady Al Omar on 06/12/1447 AH.
//

import SwiftUI

struct BePresentView: View {
    private let page: OnboardingPage
    private let onNext: () -> Void

    init(page: OnboardingPage, onNext: @escaping () -> Void) {
        self.page = page
        self.onNext = onNext
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color("BackgroundColor").ignoresSafeArea()

            BlueCircleStackView()
                .offset(x: 60, y: 140)

            VStack {
                Spacer()

                OnboardingTextBlock(
                    title: page.title,
                    subtitle: page.subtitle
                )

                Spacer().frame(height: 40)

                ZStack {
                    DotsIndicatorView(
                        totalPages: page.totalPages,
                        currentIndex: page.index
                    )
                    .frame(maxWidth: .infinity, alignment: .center)

                    HStack {
                        Spacer()

                        Button("Next") {
                            onNext()
                        }
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color("TitleColor"))
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 36)
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    BePresentView(
        page: OnboardingViewModel().pages[0],
        onNext: {}
    )
}
