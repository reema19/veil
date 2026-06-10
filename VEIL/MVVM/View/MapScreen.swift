//
//  MapScreen.swift
//  VEIL
//

import SwiftUI
import MapKit
import CoreLocation

struct MapScreen: View {

    @StateObject private var viewModel = MapViewModel()

    @State private var radius: CLLocationDistance = 1000
    @State private var showModal = false

    var onPlaceAdded: (_ placeName: String, _ activeDays: Int, _ latitude: Double, _ longitude: Double) -> Void

    var body: some View {

        ZStack {

            // MARK: - Map
            Map(coordinateRegion: $viewModel.region, showsUserLocation: true)
                .overlay(
                    Circle()
                        .stroke(Color.blue.opacity(0.5), lineWidth: 2)
                        .background(
                            Circle()
                                .fill(Color.blue.opacity(0.2))
                        )
                        .frame(
                            width: viewModel.radiusToPixels(radius),
                            height: viewModel.radiusToPixels(radius)
                        )
                        .position(
                            x: UIScreen.main.bounds.width / 2,
                            y: UIScreen.main.bounds.height / 2
                        )
                        .accessibilityHidden(true)
                )
                .ignoresSafeArea()
                .accessibilityHidden(showModal)
                .accessibilityLabel("Map")
                .accessibilityHint("Shows your current selected location")

            // MARK: - Bottom Map Controls
            VStack {

                Spacer()

                if !showModal {

                    MapRadiusControlView(radius: $radius)
                        .padding(.bottom, 10)

                    MapConfirmLocationCard(
                        address: viewModel.currentAddress,
                        onConfirm: {
                            viewModel.stopLocationUpdates()

                            withAnimation(.easeInOut) {
                                showModal = true
                            }
                        }
                    )
                    .padding(.horizontal, 28)
                }
            }
            .accessibilityHidden(showModal)

            // MARK: - Place Details Modal
            if showModal {

                Color.black.opacity(0.001)
                    .ignoresSafeArea()
                    .accessibilityHidden(true)

                ConfirmModalView(
                    address: viewModel.currentAddress,
                    onBack: {
                        withAnimation(.easeInOut) {
                            showModal = false
                        }

                        viewModel.startLocationUpdates()
                    },
                    onContinue: { placeName, activeDays in

                        let coordinate = viewModel.region.center

                        onPlaceAdded(
                            placeName,
                            activeDays,
                            coordinate.latitude,
                            coordinate.longitude
                        )
                    }
                )
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .center
                )
                .transition(.scale.combined(with: .opacity))
                .accessibilitySortPriority(10)
            }
        }
        .animation(.easeInOut, value: showModal)
        .navigationTitle(showModal ? "Place details" : "Select Location")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityElement(children: .contain)
        .onAppear {
            viewModel.startLocationUpdates()
        }
        .onDisappear {
            viewModel.stopLocationUpdates()
        }
    }
}

#Preview {
    NavigationStack {
        MapScreen(
            onPlaceAdded: { placeName, activeDays, latitude, longitude in
                print(placeName)
                print(activeDays)
                print(latitude)
                print(longitude)
            }
        )
    }
}
