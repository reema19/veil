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
    @State private var goToHomeView = false

    var onPlaceAdded: (_ placeName: String, _ activeDays: Int) -> Void

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

                        // 1. Save the place data
                        onPlaceAdded(placeName, activeDays)

                        // 2. Hide the modal
                        withAnimation(.easeInOut) {
                            showModal = false
                        }

                        // 3. Go FORWARD to HomeView, not back to Mainpage
                        goToHomeView = true
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
        .navigationDestination(isPresented: $goToHomeView) {
            HomeView()
                .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    NavigationStack {
        MapScreen(
            onPlaceAdded: { placeName, activeDays in
                print(placeName)
                print(activeDays)
            }
        )
    }
}
