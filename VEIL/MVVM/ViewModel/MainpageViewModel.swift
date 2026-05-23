//
//  MainpageViewModel.swift
//  VEIL
//
//  Created by Ghady Al Omar on 06/12/1447 AH.
//
//
//  MainpageViewModel.swift
//  ghady
//

import SwiftUI
import Combine

class MainpageViewModel: ObservableObject {
    @Published var selectedTab = 0
    @Published var pulseAnimation = false

    func startPulse() {
        pulseAnimation = true
    }

    func selectTab(_ tab: Int) {
        selectedTab = tab
    }
}
