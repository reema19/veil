//
//  HomeView.swift
//  VEIL
//

import SwiftUI

struct HomeView: View {

    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedTab: Int = 0

    var body: some View {
        ZStack {

            Color("BackgroundColor")
                .ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 26) {

                    HomeHeaderView(
                        userName: viewModel.userName,
                        onProfileTap: {
                            selectedTab = 2
                        }
                    )

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Moments of presence")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color("TitleColor"))

                        Text("Small moments of attention add up over time.")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(Color("SubtitleColor"))
                    }

                    PresenceSummaryPlaceholderView(
                        totalTime: viewModel.totalPresenceTime
                    )

                    WatchingPlacesSectionView(
                        places: viewModel.places,
                        onAddPlaceTap: {
                            print("Add place tapped")
                        }
                    )
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 110)
            }
        }
        .safeAreaInset(edge: .bottom) {
            MainTabBar(selectedTab: $selectedTab)
                .padding(.horizontal, 40)
                .padding(.bottom, 8)
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    HomeView()
}
