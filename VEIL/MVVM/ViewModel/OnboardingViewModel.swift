//
//  OnboardingViewModel.swift
//  VEIL
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
    @Published var hidePageThreeContent: Bool = false

    // MARK: - Name Entry State

    @Published var enteredName: String = ""
    @Published var hideYellowDots: Bool = false
    @Published var expandYellowCircles: Bool = false
    @Published var showNameField: Bool = false

    // MARK: - Navigation State

    @Published var goToMainpage: Bool = false


    // MARK: - Stored User Name

    @AppStorage("user_name") var savedUserName: String = ""

    @AppStorage("has_completed_onboarding")
    var hasCompletedOnboarding: Bool = false

    // MARK: - Actions

    func goToNextPage() {
        guard currentIndex < pages.count - 1 else { return }

        withAnimation(.easeInOut(duration: 0.45)) {
            currentIndex += 1
        }
    }

    func handleStart() {
        withAnimation(.easeInOut(duration: 0.25)) {
            hidePageThreeContent = true
            hideYellowDots = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { [weak self] in
            withAnimation(.easeInOut(duration: 2.9)) {
                self?.expandYellowCircles = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.15) { [weak self] in
            withAnimation(.easeInOut(duration: 1.0)) {
                self?.showNameField = true
            }
        }
    }

    func submitName() {
        let trimmedName = enteredName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else { return }

        savedUserName = trimmedName
        hasCompletedOnboarding = true
        goToMainpage = true
    }
}
