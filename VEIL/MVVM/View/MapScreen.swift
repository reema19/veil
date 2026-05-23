//
//  MapScreen.swift
//  BePresent
//
//  Created by Rahaf Alhammadi on 25/11/1447 AH.
//

import SwiftUI
import MapKit
import CoreLocation

struct MapScreen: View {

    @StateObject private var viewModel = MapViewModel()

    @State private var radius: CLLocationDistance = 1000
    @State private var showModal = false
    @State private var goToNextPage = false

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

            // MARK: - Confirm Modal
            if showModal {

                ConfirmModalView(
                    address: viewModel.currentAddress,
                    onBack: {
                        withAnimation(.easeInOut) {
                            showModal = false
                        }
                    },
                    onContinue: {
                        withAnimation(.easeInOut) {
                            showModal = false
                        }

                        goToNextPage = true
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

        // MARK: - Navigation
        // TODO: 
        .navigationDestination(isPresented: $goToNextPage) {
            Text("Next Page")
        }
    }
}

#Preview {
    NavigationStack {
        MapScreen()
    }
}
