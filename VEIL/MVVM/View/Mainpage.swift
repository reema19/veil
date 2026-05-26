//
//  Mainpage.swift
//  VEIL
//

import SwiftUI

struct Mainpage: View {

    @StateObject private var vm = MainpageViewModel()
    @StateObject private var homeViewModel = HomeViewModel()
    @StateObject private var locationPermissionViewModel = LocationPermissionViewModel()

    @AppStorage("user_name") private var userName: String = ""

    @State private var goToMapScreen = false

    @State private var showHeader = false
    @State private var showEmptyState = false
    @State private var showAddButton = false

    var body: some View {

        ZStack {

            Color("BackgroundColor")
                .ignoresSafeArea()

            VStack(spacing: 0) {

                // MARK: - Header
                HStack(spacing: 6) {
                    Text("Morning")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(Color("TitleColor"))

                    Text(userName.isEmpty ? "there" : userName)
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

                // MARK: - Empty State
                EmptyStateView(pulseAnimation: vm.pulseAnimation)
                    .opacity(showEmptyState ? 1 : 0)
                    .scaleEffect(showEmptyState ? 1 : 0.96)
                    .offset(y: showEmptyState ? 0 : 14)

                Spacer()

                // MARK: - Add Place Button
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

            // MARK: - Sheet Overlay
            if vm.showLocationSheet {

                LocationPermissionSheetView(
                    onClose: {
                        withAnimation(.spring(response: 0.35,
                                              dampingFraction: 0.85)) {
                            vm.showLocationSheet = false
                        }
                    },
                    onDone: {

                        withAnimation(.spring(response: 0.35,
                                              dampingFraction: 0.85)) {
                            vm.showLocationSheet = false
                        }

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            checkPermissionAndOpenMap()
                        }
                    }
                )
            }
        }
        .onAppear {
            vm.startPulse()
            homeViewModel.loadSavedPlaces()
            startEntranceAnimation()
        }
        .navigationDestination(isPresented: $goToMapScreen) {
            MapScreen(
                onPlaceAdded: { placeName, activeDays in
                    homeViewModel.addPlace(
                        title: placeName,
                        totalDays: activeDays
                    )
                }
            )
        }
        .onChange(of: locationPermissionViewModel.permissionGranted) { oldValue, newValue in
            if newValue {
                goToMapScreen = true
            }
        }
    }

    private func handleAddPlaceTap() {
        homeViewModel.loadSavedPlaces()

        if homeViewModel.places.isEmpty {
            withAnimation(.spring(response: 0.35,
                                  dampingFraction: 0.85)) {
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
}

#Preview {
    NavigationStack {
        Mainpage()
    }
}
