//
//  OnboardingViewModel.swift
//  VEIL
//
//  Created by Ghady Al Omar on 06/12/1447 AH.
//

import SwiftUI
import Combine

final class OnboardingViewModel: ObservableObject {

    // MARK: - Pages Data

    let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Be present.",
            subtitle: "Take a quiet moment.\nNotice what is around you.",
            imageName: "Circle1",
            index: 0,
            totalPages: 3
        ),
        OnboardingPage(
            title: "Notice with senses.",
            subtitle: "Capture one thing you see\nor one sound you hear.",
            imageName: "Circle2",
            index: 1,
            totalPages: 3
        ),
        OnboardingPage(
            title: "keep the moment.",
            subtitle: "Your place becomes a memory\nyou can return to later.",
            imageName: "Circle3",
            index: 2,
            totalPages: 3
        )
    ]

    // MARK: - Current Page State

    @Published var currentIndex: Int = 0

    // MARK: - Page 3 State

    @Published var isAnimating: Bool = false
    @Published var showStartCentered: Bool = false

    // MARK: - Navigation State

    @Published var goToMainpage: Bool = false

    // MARK: - Actions

    func goToNextPage() {
        guard currentIndex < pages.count - 1 else { return }

        withAnimation(.easeInOut(duration: 0.45)) {
            currentIndex += 1
        }
    }

    func startAnimations() {
        guard isAnimating == false else { return }

        isAnimating = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            withAnimation {
                self?.showStartCentered = true
            }
        }
    }

    func handleStart() {
        goToMainpage = true
    }
}
