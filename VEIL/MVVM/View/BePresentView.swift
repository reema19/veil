//
//  BePresentView.swift
//  VEIL
//
//  Created by Ghady Al Omar on 06/12/1447 AH.
//
//

import SwiftUI

struct BePresentView: View {
    private let page: OnboardingPage

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
                    .offset(x: 40, y: 40)
            }
            .offset(x: 30, y: 40)

            VStack {
                Spacer()

                OnboardingTextBlock(title: page.title, subtitle: page.subtitle)

                Spacer().frame(height: 90)

                HStack {
                    DotsIndicatorView(totalPages: page.totalPages, currentIndex: page.index)
                    Spacer()
                    NavigationLink("Next") {
                        BePresentView2(page: OnboardingViewModel().pages[1])
                    }
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color("TitleColor"))
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 36)
            }
        }
        .navigationBarHidden(true)
    }
}
#Preview {
    BePresentView(page: OnboardingViewModel().pages[0])
}
