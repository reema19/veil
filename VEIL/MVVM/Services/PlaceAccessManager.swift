//
//  PlaceAccessManager.swift
//  VEIL
//

import Foundation
import CoreLocation

enum PlaceAccessResult {
    case allowed
    case outside(distance: CLLocationDistance, radius: CLLocationDistance)
    case locationPermissionDenied
    case locationUnavailable
}

final class PlaceAccessManager: NSObject, CLLocationManagerDelegate {

    static let shared = PlaceAccessManager()

    private let locationManager = CLLocationManager()

    private var pendingPlaceLocation: CLLocation?
    private var pendingRadius: CLLocationDistance?
    private var pendingCompletion: ((PlaceAccessResult) -> Void)?

    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }

    func checkAccess(
        to place: Place,
        completion: @escaping (PlaceAccessResult) -> Void
    ) {
        checkAccess(
            latitude: place.latitude,
            longitude: place.longitude,
            radius: place.radiusMeters,
            completion: completion
        )
    }

    func checkAccess(
        latitude: Double,
        longitude: Double,
        radius: CLLocationDistance,
        completion: @escaping (PlaceAccessResult) -> Void
    ) {
        let status = locationManager.authorizationStatus

        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            pendingPlaceLocation = CLLocation(latitude: latitude, longitude: longitude)
            pendingRadius = radius
            pendingCompletion = completion
            locationManager.requestLocation()

        case .notDetermined:
            pendingPlaceLocation = CLLocation(latitude: latitude, longitude: longitude)
            pendingRadius = radius
            pendingCompletion = completion
            locationManager.requestWhenInUseAuthorization()

        case .denied, .restricted:
            completion(.locationPermissionDenied)

        @unknown default:
            completion(.locationUnavailable)
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            if pendingCompletion != nil {
                locationManager.requestLocation()
            }

        case .denied, .restricted:
            complete(.locationPermissionDenied)

        case .notDetermined:
            break

        @unknown default:
            complete(.locationUnavailable)
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard
            let userLocation = locations.last,
            let placeLocation = pendingPlaceLocation,
            let radius = pendingRadius
        else {
            complete(.locationUnavailable)
            return
        }

        let distance = userLocation.distance(from: placeLocation)

        if distance <= radius {
            complete(.allowed)
        } else {
            complete(.outside(distance: distance, radius: radius))
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        print("Place access location failed:", error.localizedDescription)
        complete(.locationUnavailable)
    }

    private func complete(_ result: PlaceAccessResult) {
        DispatchQueue.main.async {
            self.pendingCompletion?(result)

            self.pendingPlaceLocation = nil
            self.pendingRadius = nil
            self.pendingCompletion = nil
        }
    }
}
