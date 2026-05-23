//
//  Mainpage.swift
//  VEIL
//
//  Created by Ghady Al Omar on 06/12/1447 AH.
//

//
//  Mainpage.swift
//  ghady
//
//  Created by Ghady Al Omar on 24/11/1447 AH.
//

import SwiftUI

struct Mainpage: View {
    @StateObject private var vm = MainpageViewModel()

    var body: some View {
        ZStack {
            Color("BackgroundColor").ignoresSafeArea()

            VStack(spacing: 0) {

                // MARK: - Header
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Good morning,")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(Color("SubtitleColor"))
                        Text("ghady")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(Color("TitleColor"))
                    }
                    Spacer()
                    Button(action: {}) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color("TitleColor"))
                            .frame(width: 48, height: 48)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .strokeBorder(Color("TitleColor").opacity(0.15), lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal, 28)
                .padding(.top, 20)
                .padding(.bottom, 8)

                Spacer()

                // MARK: - Empty State
                EmptyStateView(pulseAnimation: vm.pulseAnimation)

                Spacer()

                // MARK: - Tab Bar
                MainTabBar(selectedTab: $vm.selectedTab)
                    .padding(.horizontal, 28)
                    .padding(.bottom, 24)
            }
        }
        .onAppear {
            vm.startPulse()
        }
    }
}

#Preview {
    Mainpage()
}
