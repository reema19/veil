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
                )
                .ignoresSafeArea()

            // MARK: - Bottom Map Controls
            VStack {

                Spacer()

                if !showModal {

                    MapRadiusControlView(radius: $radius)
                        .padding(.bottom, 10)

                    MapConfirmLocationCard(
                        address: viewModel.currentAddress,
                        onConfirm: {
                            viewModel.startMonitoringSelectedRegion(radius: radius)

                            withAnimation(.easeInOut) {
                                showModal = true
                            }
                        }
                    )
                    .padding(.horizontal, 28)
                }
            }

            // MARK: - Place Details Modal
            if showModal {

                ConfirmModalView(
                    address: viewModel.currentAddress,
                    onBack: {
                        withAnimation(.easeInOut) {
                            showModal = false
                        }
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
            }
        }
        .animation(.easeInOut, value: showModal)
        .navigationTitle("Select Location")
        .navigationBarTitleDisplayMode(.inline)

        // MARK: - Navigate To HomeView
        
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
