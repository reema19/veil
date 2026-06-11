//
//  MapScreen.swift
//  VEIL
//

import SwiftUI
import MapKit
import CoreLocation

struct MapScreen: View {

    @StateObject private var viewModel = MapViewModel()

    private let defaultRadius: CLLocationDistance = 5000

    @State private var showModal = false

    var onPlaceAdded: (
        _ placeName: String,
        _ activeDays: Int,
        _ latitude: Double,
        _ longitude: Double,
        _ radius: CLLocationDistance
    ) -> Void

    var body: some View {

        ZStack {

            // MARK: - Map
            Map(position: $viewModel.cameraPosition, interactionModes: .all) {
                UserAnnotation()
            }
            .mapControls {
                MapCompass()
                MapScaleView()
            }
            .onMapCameraChange(frequency: .onEnd) { context in
                viewModel.updateSelectedCoordinate(context.region.center)
            }
            .ignoresSafeArea()
            .accessibilityHidden(showModal)
            .accessibilityLabel("Map")
            .accessibilityHint("Move the map to choose the center of your place")

            // MARK: - Center Pin
            if !showModal {
                Image(systemName: "mappin")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundColor(.blue)
                    .shadow(
                        color: .black.opacity(0.18),
                        radius: 4,
                        x: 0,
                        y: 2
                    )
                    .offset(y: -52)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }

            

            // MARK: - Location Error Message
            if let locationMessage = viewModel.locationMessage, !showModal {
                VStack {
                    Text(locationMessage)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color("TitleColor"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .padding(.horizontal, 24)

                    Spacer()
                }
                .padding(.top, 18)
            }

            // MARK: - Bottom Map Controls
            VStack {

                Spacer()
                if !showModal {
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
                    radius: defaultRadius,
                    onBack: {
                        withAnimation(.easeInOut) {
                            showModal = false
                        }

                        viewModel.startLocationUpdates()
                    },
                    onContinue: { placeName, activeDays in

                        let coordinate = viewModel.selectedCoordinate

                        onPlaceAdded(
                            placeName,
                            activeDays,
                            coordinate.latitude,
                            coordinate.longitude,
                            defaultRadius
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
        .toolbar {
            if !showModal {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.centerOnUserLocation()
                    } label: {
                        Image(systemName: "location")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color("TitleColor"))
                            
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Use my current location")
                }
            }
        }
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
            onPlaceAdded: { placeName, activeDays, latitude, longitude, radius in
                print(placeName)
                print(activeDays)
                print(latitude)
                print(longitude)
                print(radius)
            }
        )
    }
}
