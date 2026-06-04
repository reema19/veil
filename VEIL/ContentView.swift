//
//  ContentView.swift
//  VEIL
//
//  Created by reema aljohani on 5/23/26.
//
import SwiftUI
import SwiftData

struct ContentView: View {

    @AppStorage("has_completed_onboarding") private var hasCompletedOnboarding: Bool = false

    @Query(
        filter: #Predicate<Place> { place in
            place.deletedAt == nil && place.statusRawValue == "active"
        },
        sort: \Place.createdAt,
        order: .reverse
    )
    private var activePlaces: [Place]

    @State private var rootID = UUID()

    var body: some View {
        NavigationStack {
            if hasCompletedOnboarding {
                if activePlaces.isEmpty {
                    Mainpage()
                } else {
                    HomeView()
                }
            } else {
                OnboardingView()
            }
        }
        .id(rootID)
        .onReceive(NotificationCenter.default.publisher(for: .observationSavedGoHome)) { _ in
            rootID = UUID()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [
            LocalProfile.self,
            Place.self,
            PlaceObservation.self
        ], inMemory: true)
}
