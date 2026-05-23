//
//  BePresentView2.swift
//  VEIL
//
//  Created by Ghady Al Omar on 06/12/1447 AH.
//
//


import SwiftUI

struct BePresentView2: View {
    private let page: OnboardingPage

    init(page: OnboardingPage) {
        self.page = page
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color("BackgroundColor").ignoresSafeArea()

            VStack {
                Spacer()

                OnboardingTextBlock(title: page.title, subtitle: page.subtitle)

                Spacer().frame(height: 90)

                ZStack {
                    Image(page.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 360, height: 400)
                        .offset(x: -10, y: 0)
                }
                .offset(x: 70, y: -20)

                HStack {
                    DotsIndicatorView(totalPages: page.totalPages, currentIndex: page.index)
                    Spacer()
                    NavigationLink("Next") {
                        BePresentView3(page: OnboardingViewModel().pages[2])
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
    BePresentView2(page: OnboardingViewModel().pages[1])
}
