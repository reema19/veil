//
//  MainpageViewModel.swift
//  VEIL
//

import SwiftUI
import Combine

class MainpageViewModel: ObservableObject {

    @Published var pulseAnimation = false
    @Published var showLocationSheet = false

    func startPulse() {
        pulseAnimation = true
    }
}
