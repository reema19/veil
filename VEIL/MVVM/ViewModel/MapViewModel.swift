//
//  MapViewModel.swift
//  VEIL
//
//  Created by Rahaf Alhammadi on 25/11/1447 AH.
//

import SwiftUI
import MapKit
import CoreLocation
import Combine

final class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {

    @Published var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 24.7136, longitude: 46.6753),
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )
    )

    @Published var selectedCoordinate = CLLocationCoordinate2D(
        latitude: 24.7136,
        longitude: 46.6753
    )

    @Published var currentAddress: String = "Move the map to choose your place"
    @Published var isFindingUserLocation = false
    @Published var locationMessage: String?

    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    private var shouldCenterOnNextLocationUpdate = false
    private var didCenterOnUserLocation = false
    private var latestUserLocation: CLLocation?
    private var geocodeWorkItem: DispatchWorkItem?

    override init() {
        super.init()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10
    }

    // MARK: - Public Functions

    func startLocationUpdates() {
        locationMessage = nil

        switch locationManager.authorizationStatus {
        case .notDetermined:
            isFindingUserLocation = true
            locationManager.requestWhenInUseAuthorization()

        case .authorizedWhenInUse, .authorizedAlways:
            isFindingUserLocation = true
            locationManager.startUpdatingLocation()
            locationManager.requestLocation()

        case .denied, .restricted:
            isFindingUserLocation = false
            locationMessage = "Location access is off. You can still move the map manually."

        @unknown default:
            isFindingUserLocation = false
            locationMessage = "We could not check your location. You can still move the map manually."
        }
    }

    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
        geocoder.cancelGeocode()
        geocodeWorkItem?.cancel()
    }

    func centerOnUserLocation() {
        locationMessage = nil
        isFindingUserLocation = true
        shouldCenterOnNextLocationUpdate = true

        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()

        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
            locationManager.requestLocation()

            // Use the latest known location immediately while waiting for a fresh update.
            if let latestUserLocation {
                moveCamera(to: latestUserLocation.coordinate)
            }

        case .denied, .restricted:
            isFindingUserLocation = false
            shouldCenterOnNextLocationUpdate = false
            locationMessage = "Location access is off. Please enable it in Settings or move the map manually."

        @unknown default:
            isFindingUserLocation = false
            shouldCenterOnNextLocationUpdate = false
            locationMessage = "We could not check your location. Please move the map manually."
        }
    }

    func updateSelectedCoordinate(_ coordinate: CLLocationCoordinate2D) {
        selectedCoordinate = coordinate

        let location = CLLocation(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )

        reverseGeocodeWithDelay(location)
    }

    // MARK: - CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            isFindingUserLocation = true
            locationMessage = nil
            locationManager.startUpdatingLocation()
            locationManager.requestLocation()

        case .denied, .restricted:
            isFindingUserLocation = false
            locationMessage = "Location access is off. You can still move the map manually."

        case .notDetermined:
            break

        @unknown default:
            isFindingUserLocation = false
            locationMessage = "We could not check your location. You can still move the map manually."
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.last else { return }

        latestUserLocation = location
        isFindingUserLocation = false

        if !didCenterOnUserLocation || shouldCenterOnNextLocationUpdate {
            didCenterOnUserLocation = true
            shouldCenterOnNextLocationUpdate = false
            moveCamera(to: location.coordinate)
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        isFindingUserLocation = false
        locationMessage = "We could not find your location. You can still move the map manually."
        print("Map location failed:", error.localizedDescription)
    }

    // MARK: - Private Helpers

    private func moveCamera(to coordinate: CLLocationCoordinate2D) {
        selectedCoordinate = coordinate

        let region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )

        withAnimation(.easeInOut(duration: 0.45)) {
            cameraPosition = .region(region)
        }

        reverseGeocodeWithDelay(
            CLLocation(
                latitude: coordinate.latitude,
                longitude: coordinate.longitude
            )
        )
    }

    private func reverseGeocodeWithDelay(_ location: CLLocation) {
        geocodeWorkItem?.cancel()

        let workItem = DispatchWorkItem { [weak self] in
            self?.reverseGeocode(location)
        }

        geocodeWorkItem = workItem

        DispatchQueue.main.asyncAfter(
            deadline: .now() + 0.45,
            execute: workItem
        )
    }

    private func reverseGeocode(_ location: CLLocation) {
        geocoder.cancelGeocode()

        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, _ in
            guard let self else { return }

            DispatchQueue.main.async {
                if let place = placemarks?.first {
                    let addressParts = [
                        place.name,
                        place.locality,
                        place.administrativeArea,
                        place.country
                    ]
                    .compactMap { $0 }
                    .filter { !$0.isEmpty }

                    if addressParts.isEmpty {
                        self.currentAddress = "Selected location"
                    } else {
                        self.currentAddress = addressParts.joined(separator: ", ")
                    }
                } else {
                    self.currentAddress = "Selected location"
                }
            }
        }
    }
}
