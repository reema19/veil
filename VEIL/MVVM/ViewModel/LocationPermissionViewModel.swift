//
//  LocationPermissionViewModel.swift
//  VEIL
//

import Foundation
import Combine
import CoreLocation

class LocationPermissionViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {

    @Published var permissionGranted = false
    @Published var permissionDenied = false

    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
        checkCurrentPermission()
    }

    func checkCurrentPermission() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            permissionGranted = true
            permissionDenied = false

        case .denied, .restricted:
            permissionGranted = false
            permissionDenied = true

        case .notDetermined:
            permissionGranted = false
            permissionDenied = false

        @unknown default:
            permissionGranted = false
            permissionDenied = false
        }
    }

    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkCurrentPermission()
    }
}
