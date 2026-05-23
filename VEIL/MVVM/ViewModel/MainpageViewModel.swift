//
//  MainpageViewModel.swift
//  VEIL
//
//  Created by Ghady Al Omar on 06/12/1447 AH.
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
