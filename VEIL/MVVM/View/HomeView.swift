//
//  HomeView.swift
//  VEIL
//

import SwiftUI
import SwiftData

struct HomeView: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @Query(
        filter: #Predicate<Place> { place in
            place.deletedAt == nil && place.statusRawValue == "active"
        },
        sort: \Place.createdAt,
        order: .forward
    )
    private var activePlaces: [Place]

    @Query(
        filter: #Predicate<Place> { place in
            place.deletedAt == nil
        },
        sort: \Place.createdAt,
        order: .forward
    )
    private var allPlaces: [Place]

    @Query(sort: \LocalProfile.createdAt, order: .forward)
    private var profiles: [LocalProfile]

    @State private var selectedTab: Int = 0
    @State private var goToMapScreen = false
    @State private var goToProfile = false
    @State private var showMaxPlacesAlert = false

    private let lifecycleService = PlaceLifecycleService()

    private var isAccessibilitySize: Bool {
        dynamicTypeSize.isAccessibilitySize
    }

    private var pageSpacing: CGFloat {
        isAccessibilitySize ? 32 : 26
    }

    private var horizontalPadding: CGFloat {
        isAccessibilitySize ? 20 : 24
    }

    private var totalPresenceTime: String {
        let totalSeconds = activePlaces.reduce(0) { $0 + $1.totalPresenceSeconds }
        return formatDuration(totalSeconds)
    }

    private var displayName: String {
        let name = profiles.first?.displayName
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        return name.isEmpty ? "there" : name
    }

    var body: some View {
        ZStack {

            Color("BackgroundColor")
                .ignoresSafeArea()

            if selectedTab == 0 {
                homeContent
            } else {
                ArchiveView(
                    places: Array(allPlaces.prefix(3)),
                    onProfileTap: {
                        goToProfile = true
                    }
                )
            }
        }
        .safeAreaInset(edge: .bottom) {
            MainTabBar(selectedTab: $selectedTab)
                .padding(.horizontal, isAccessibilitySize ? 24 : 40)
                .padding(.bottom, 8)
        }
        .onAppear {
            lifecycleService.updateExpiredPlaces(activePlaces, context: modelContext)
        }
        .alert("Maximum places reached", isPresented: $showMaxPlacesAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("You can only watch 3 places at a time. Later, when one is deleted or finished, you can add another place.")
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

                    goToMapScreen = false
                }
            )
        }
        .navigationDestination(isPresented: $goToProfile) {
            ProfileView()
        }
    }

    private var homeContent: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: pageSpacing) {

                HomeHeaderView(
                    userName: displayName,
                    onProfileTap: {
                        goToProfile = true
                    }
                )

                VStack(alignment: .leading, spacing: 8) {
                    Text("Moments of presence")
                        .font(.custom("DMSans-Bold", size: 20, relativeTo: .title3))
                        .foregroundColor(Color("TitleColor"))
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityAddTraits(.isHeader)

                    Text("Small moments of attention add up over time.")
                        .font(.custom("DMSans-Regular", size: 13, relativeTo: .body))
                        .foregroundColor(Color("SubtitleColor"))
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }

                PresenceSummaryPlaceholderView(
                    totalTime: totalPresenceTime
                )

                WatchingPlacesSectionView(
                    places: Array(activePlaces.prefix(3)),
                    onAddPlaceTap: {
                        openMapIfAllowed()
                    }
                )
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.top, 20)
            .padding(.bottom, isAccessibilitySize ? 140 : 110)
        }
    }

    private func openMapIfAllowed() {
        guard activePlaces.count < 3 else {
            showMaxPlacesAlert = true
            return
        }

        goToMapScreen = true
    }

    private func addPlace(
        name: String,
        activeDays: Int,
        latitude: Double,
        longitude: Double
    ) {
        guard activePlaces.count < 3 else {
            showMaxPlacesAlert = true
            return
        }

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
    }
    .modelContainer(for: [
        LocalProfile.self,
        Place.self,
        PlaceObservation.self
    ], inMemory: true)
}
