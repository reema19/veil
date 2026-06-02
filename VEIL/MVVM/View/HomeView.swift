//
//  HomeView.swift
//  VEIL
//

import SwiftUI
import SwiftData

struct HomeView: View {

    @Environment(\.modelContext) private var modelContext

    @Query(
        filter: #Predicate<Place> { place in
            place.deletedAt == nil && place.statusRawValue == "active"
        },
        sort: \Place.createdAt,
        order: .reverse
    )
    private var activePlaces: [Place]

    @State private var selectedTab: Int = 0
    @State private var goToMapScreen = false

    private let lifecycleService = PlaceLifecycleService()

    private var totalPresenceTime: String {
        let totalSeconds = activePlaces.reduce(0) { $0 + $1.totalPresenceSeconds }
        return formatDuration(totalSeconds)
    }

    private var displayName: String {
        UserDefaults.standard.string(forKey: "user_name") ?? "there"
    }

    var body: some View {
        ZStack {

            Color("BackgroundColor")
                .ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 26) {

                    HomeHeaderView(
                        userName: displayName.isEmpty ? "there" : displayName,
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
                        totalTime: totalPresenceTime
                    )

                    WatchingPlacesSectionView(
                        places: activePlaces,
                        onAddPlaceTap: {
                            goToMapScreen = true
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
        .onAppear {
            lifecycleService.updateExpiredPlaces(activePlaces, context: modelContext)
        }
        .navigationDestination(isPresented: $goToMapScreen) {
            MapScreen(
                onPlaceAdded: { placeName, activeDays, latitude, longitude in
                    addPlace(
                        name: placeName,
                        activeDays: activeDays,
                        latitude: latitude,
                        longitude: longitude
                    )
                }
            )
        }
    }

    private func addPlace(
        name: String,
        activeDays: Int,
        latitude: Double,
        longitude: Double
    ) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        let safeActiveDays = min(max(activeDays, 1), 7)

        let place = Place(
            name: trimmedName,
            latitude: latitude,
            longitude: longitude,
            activeDays: safeActiveDays
        )

        modelContext.insert(place)

        do {
            try modelContext.save()
        } catch {
            print("Failed to save place:", error)
        }
    }

    private func formatDuration(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let remainingSeconds = seconds % 60

        return String(format: "%02d:%02d:%02d", hours, minutes, remainingSeconds)
    }
}

#Preview {
    NavigationStack {
        HomeView()
            .modelContainer(for: [
                LocalProfile.self,
                Place.self,
                PlaceObservation.self
            ], inMemory: true)
    }
}
