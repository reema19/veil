//
//  Mainpage.swift
//  VEIL
//

import SwiftUI
import SwiftData
import CoreLocation

struct Mainpage: View {

    @Environment(\.modelContext) private var modelContext

    @Query(
        filter: #Predicate<Place> { place in
            place.deletedAt == nil && place.statusRawValue == "active"
        },
        sort: \Place.createdAt,
        order: .reverse
    )
    private var activePlaces: [Place]

    @Query(sort: \LocalProfile.createdAt, order: .forward)
    private var profiles: [LocalProfile]

    @StateObject private var vm = MainpageViewModel()
    @StateObject private var locationPermissionViewModel = LocationPermissionViewModel()

    @State private var goToMapScreen = false

    @AppStorage("whenYouArriveEnabled")
    private var whenYouArriveEnabled = true

    @State private var showHeader = false
    @State private var showEmptyState = false
    @State private var showAddButton = false
    @State private var showHomeView = false

    private var displayName: String {
        let name = profiles.first?.displayName
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        return name.isEmpty ? "there" : name
    }

    var body: some View {

        ZStack {

            if showHomeView {
                HomeView()
                    .navigationBarBackButtonHidden(true)
            } else {

                Color("BackgroundColor")
                    .ignoresSafeArea()

                VStack(spacing: 0) {

                    HStack(spacing: 6) {
                        Text("Morning")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(Color("TitleColor"))

                        Text(displayName)
                            .font(.system(size: 30, weight: .regular))
                            .foregroundColor(Color("TitleColor"))

                        Spacer()
                    }
                    .padding(.horizontal, 38)
                    .padding(.top, 20)
                    .padding(.bottom, -8)
                    .opacity(showHeader ? 1 : 0)
                    .offset(y: showHeader ? 0 : 10)

                    Spacer()

                    EmptyStateView(pulseAnimation: vm.pulseAnimation)
                        .opacity(showEmptyState ? 1 : 0)
                        .scaleEffect(showEmptyState ? 1 : 0.96)
                        .offset(y: showEmptyState ? 0 : 14)

                    Spacer()

                    Button(action: {
                        handleAddPlaceTap()
                    }) {
                        HStack(spacing: 8) {
                            Text("Add a place")
                                .font(.system(size: 17, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: 318)
                        .frame(height: 52)
                        .background(Color.black)
                        .cornerRadius(25)
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 24)
                    .opacity(showAddButton ? 1 : 0)
                    .offset(y: showAddButton ? 0 : 14)
                }

                if vm.showLocationSheet {

                    LocationPermissionSheetView(
                        onClose: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                vm.showLocationSheet = false
                            }
                        },
                        onDone: {

                            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                vm.showLocationSheet = false
                            }

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                checkPermissionAndOpenMap()
                            }
                        }
                    )
                }
            }
        }
        .onAppear {
            vm.startPulse()

            if activePlaces.isEmpty {
                startEntranceAnimation()
            } else {
                showHomeView = true
            }
        }
        .navigationDestination(isPresented: $goToMapScreen) {
            MapScreen(
                onPlaceAdded: { placeName, activeDays, latitude, longitude, radius in
                    addPlace(
                        name: placeName,
                        activeDays: activeDays,
                        latitude: latitude,
                        longitude: longitude,
                        radiusMeters: radius
                    )

                    goToMapScreen = false
                    showHomeView = true
                }
            )
        }
        .onChange(of: locationPermissionViewModel.permissionGranted) { _, newValue in
            if newValue {
                goToMapScreen = true
            }
        }
    }

    private func handleAddPlaceTap() {
        if activePlaces.isEmpty {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                vm.showLocationSheet = true
            }
        } else {
            checkPermissionAndOpenMap()
        }
    }

    private func checkPermissionAndOpenMap() {
        locationPermissionViewModel.checkCurrentPermission()

        if locationPermissionViewModel.permissionGranted {
            goToMapScreen = true
        } else {
            locationPermissionViewModel.requestPermission()
        }
    }

    private func startEntranceAnimation() {
        showHeader = false
        showEmptyState = false
        showAddButton = false

        withAnimation(.easeInOut(duration: 0.55)) {
            showHeader = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            withAnimation(.spring(response: 0.75, dampingFraction: 0.9)) {
                showEmptyState = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.34) {
            withAnimation(.easeInOut(duration: 0.55)) {
                showAddButton = true
            }
        }
    }

    private func addPlace(
        name: String,
        activeDays: Int,
        latitude: Double,
        longitude: Double,
        radiusMeters: CLLocationDistance
    ) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        let safeActiveDays = min(max(activeDays, 1), 7)

        let place = Place(
            name: trimmedName,
            latitude: latitude,
            longitude: longitude,
            radiusMeters: radiusMeters,
            activeDays: safeActiveDays
        )

        modelContext.insert(place)

        do {
            try modelContext.save()

            if whenYouArriveEnabled {
                LocationReminderManager.shared.startMonitoringPlace(place)
            }

        } catch {
            print("Failed to save place from Mainpage:", error)
        }
    }
}

#Preview {
    NavigationStack {
        Mainpage()
            .modelContainer(for: [
                LocalProfile.self,
                Place.self,
                PlaceObservation.self
            ], inMemory: true)
    }
}
