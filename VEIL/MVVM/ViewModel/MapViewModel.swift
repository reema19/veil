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

    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 24.7136, longitude: 46.6753),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    @Published var currentAddress: String = "Fetching current location..."

    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()

    private var didSetInitialLocation = false
    private var lastGeocodedLocation: CLLocation?

    override init() {
        super.init()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func startLocationUpdates() {
        locationManager.startUpdatingLocation()
    }

    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
        geocoder.cancelGeocode()
    }

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.last else { return }

        if !didSetInitialLocation {
            didSetInitialLocation = true

            DispatchQueue.main.async {
                self.region.center = location.coordinate
            }
        }

        if shouldReverseGeocode(location) {
            reverseGeocode(location)
        }
    }

    private func shouldReverseGeocode(_ location: CLLocation) -> Bool {
        guard let lastGeocodedLocation else {
            lastGeocodedLocation = location
            return true
        }

        let distance = location.distance(from: lastGeocodedLocation)

        if distance >= 100 {
            self.lastGeocodedLocation = location
            return true
        }

        return false
    }

    private func reverseGeocode(_ location: CLLocation) {
        geocoder.cancelGeocode()

        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, _ in
            guard let self else { return }

            if let place = placemarks?.first {
                let addressParts = [
                    place.name,
                    place.locality,
                    place.country
                ]
                .compactMap { $0 }
                .filter { !$0.isEmpty }

                DispatchQueue.main.async {
                    self.currentAddress = addressParts.joined(separator: ", ")
                }
            }
        }
    }

    func radiusToPixels(_ radius: CLLocationDistance) -> CGFloat {
        CGFloat(radius / 1000.0) * 150
    }
}
