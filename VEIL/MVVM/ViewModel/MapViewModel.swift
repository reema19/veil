//
//  MapViewModel.swift
//  BePresent
//
//  Created by Rahaf Alhammadi on 25/11/1447 AH.
//

import SwiftUI
import Combine
import MapKit
import CoreLocation

class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {

    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 24.7136, longitude: 46.6753),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    @Published var currentAddress: String = "Fetching current location..."

    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()

    override init() {
        super.init()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }

    // MARK: - Location Updates
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.last else { return }

        DispatchQueue.main.async {
            self.region.center = location.coordinate
        }

        reverseGeocode(location)
    }

    // MARK: - Reverse Geocode
    private func reverseGeocode(_ location: CLLocation) {

        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, _ in

            guard let self = self else { return }

            if let place = placemarks?.first {

                var address = ""

                if let name = place.name {
                    address += name
                }

                if let city = place.locality {
                    address += ", \(city)"
                }

                if let country = place.country {
                    address += ", \(country)"
                }

                DispatchQueue.main.async {
                    self.currentAddress = address
                }
            }
        }
    }

    // MARK: - Start Monitoring Selected Region
    func startMonitoringSelectedRegion(radius: CLLocationDistance) {

        let center = region.center

        let selectedRegion = CLCircularRegion(
            center: center,
            radius: radius,
            identifier: "SelectedRegion"
        )

        selectedRegion.notifyOnEntry = true
        selectedRegion.notifyOnExit = true

        locationManager.requestAlwaysAuthorization()
        locationManager.startMonitoring(for: selectedRegion)

        print("Monitoring region at \(center.latitude), \(center.longitude) with radius = \(radius / 1000) km")
    }

    // MARK: - Radius UI Helper
    func radiusToPixels(_ radius: CLLocationDistance) -> CGFloat {

        // Visual approximation only.
        // 1 km ≈ 150 px.
        let scale = CGFloat(radius / 1000.0) * 150

        return scale
    }
}
