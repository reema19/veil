//
//  MainpageViewModel.swift
//  VEIL
//

import SwiftUI
import Combine
final class MainpageViewModel: ObservableObject {

    @Published var pulseAnimation = false
    @Published var showLocationSheet = false

    func startPulse() {
        pulseAnimation = true
    }
}
