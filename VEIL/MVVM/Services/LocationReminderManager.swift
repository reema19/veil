//
//  LocationReminderManager.swift
//  VEIL
//

import Foundation
import CoreLocation
import UserNotifications

final class LocationReminderManager: NSObject, CLLocationManagerDelegate {

    static let shared = LocationReminderManager()

    private let locationManager = CLLocationManager()
    private let regionIdentifierPrefix = "veil-place-region-"

    private var pendingPlaceToMonitor: PendingPlace?

    private struct PendingPlace {
        let id: UUID
        let name: String
        let latitude: Double
        let longitude: Double
        let radius: CLLocationDistance
    }

    private override init() {
        super.init()
        locationManager.delegate = self
    }

    // MARK: - Permission

    func requestAlwaysLocationPermission() {
        locationManager.requestAlwaysAuthorization()
    }

    func getLocationPermissionStatus() -> CLAuthorizationStatus {
        locationManager.authorizationStatus
    }

    var hasAlwaysPermission: Bool {
        locationManager.authorizationStatus == .authorizedAlways
    }

    // MARK: - Start Monitoring

    func startMonitoringPlace(
        id: UUID,
        name: String,
        latitude: Double,
        longitude: Double,
        radius: CLLocationDistance
    ) {
        guard CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) else {
            print("Region monitoring is not available on this device.")
            return
        }

        guard hasAlwaysPermission else {
            print("Always location permission is not granted yet. Saving place as pending.")

            pendingPlaceToMonitor = PendingPlace(
                id: id,
                name: name,
                latitude: latitude,
                longitude: longitude,
                radius: radius
            )

            requestAlwaysLocationPermission()
            return
        }

        startMonitoringRegion(
            id: id,
            name: name,
            latitude: latitude,
            longitude: longitude,
            radius: radius
        )
    }

    func startMonitoringPlace(_ place: Place) {
        startMonitoringPlace(
            id: place.id,
            name: place.name,
            latitude: place.latitude,
            longitude: place.longitude,
            radius: place.radiusMeters
        )
    }

    // MARK: - Stop Monitoring

    func stopMonitoringPlace(id: UUID) {
        let identifier = regionIdentifier(for: id)

        for region in locationManager.monitoredRegions {
            if region.identifier == identifier {
                locationManager.stopMonitoring(for: region)
                print("Stopped monitoring region:", identifier)
            }
        }
    }

    func stopMonitoringPlace(_ place: Place) {
        stopMonitoringPlace(id: place.id)
    }

    func stopAllVEILPlaceMonitoring() {
        for region in locationManager.monitoredRegions {
            if region.identifier.hasPrefix(regionIdentifierPrefix) {
                locationManager.stopMonitoring(for: region)
                print("Stopped VEIL region:", region.identifier)
            }
        }
    }

    // MARK: - Debug

    func printMonitoredRegions() {
        print("Currently monitored regions count:", locationManager.monitoredRegions.count)

        for region in locationManager.monitoredRegions {
            print("Monitored region:", region.identifier)
        }
    }

    // MARK: - CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        print("Location authorization changed:", status.rawValue)

        if status == .authorizedAlways, let pendingPlaceToMonitor {
            print("Always permission granted. Starting pending place monitoring.")

            startMonitoringRegion(
                id: pendingPlaceToMonitor.id,
                name: pendingPlaceToMonitor.name,
                latitude: pendingPlaceToMonitor.latitude,
                longitude: pendingPlaceToMonitor.longitude,
                radius: pendingPlaceToMonitor.radius
            )

            self.pendingPlaceToMonitor = nil
        }
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard region.identifier.hasPrefix(regionIdentifierPrefix) else {
            return
        }

        print("Entered VEIL place region:", region.identifier)
        sendArrivalNotification(for: region)
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        guard region.identifier.hasPrefix(regionIdentifierPrefix) else {
            return
        }

        print("Exited VEIL place region:", region.identifier)
    }

    func locationManager(
        _ manager: CLLocationManager,
        didDetermineState state: CLRegionState,
        for region: CLRegion
    ) {
        guard region.identifier.hasPrefix(regionIdentifierPrefix) else {
            return
        }

        switch state {
        case .inside:
            print("User is already inside VEIL place region:", region.identifier)
            sendArrivalNotification(for: region)

        case .outside:
            print("User is outside VEIL place region:", region.identifier)

        case .unknown:
            print("VEIL place region state is unknown:", region.identifier)
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        monitoringDidFailFor region: CLRegion?,
        withError error: Error
    ) {
        print("Region monitoring failed:", error.localizedDescription)

        if let region {
            print("Failed region:", region.identifier)
        }
    }

    // MARK: - Private Helpers

    private func startMonitoringRegion(
        id: UUID,
        name: String,
        latitude: Double,
        longitude: Double,
        radius: CLLocationDistance
    ) {
        let center = CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude
        )

        let identifier = regionIdentifier(for: id)

        // Stop old monitoring for the same place before starting a fresh one.
        stopMonitoringPlace(id: id)

        let safeRadius = adjustedRadius(radius)

        let region = CLCircularRegion(
            center: center,
            radius: safeRadius,
            identifier: identifier
        )

        region.notifyOnEntry = true
        region.notifyOnExit = true

        locationManager.startMonitoring(for: region)

        // This is the important part:
        // It checks if the user is already inside the place radius.
        locationManager.requestState(for: region)

        print("Started monitoring place:", name)
        print("Region identifier:", region.identifier)
        print("Latitude:", latitude)
        print("Longitude:", longitude)
        print("Requested radius:", radius)
        print("Used radius:", safeRadius)
    }

    private func adjustedRadius(_ radius: CLLocationDistance) -> CLLocationDistance {
        let maximumDistance = locationManager.maximumRegionMonitoringDistance

        if maximumDistance > 0 && radius > maximumDistance {
            print("Radius is larger than maximum region monitoring distance. Adjusting radius to:", maximumDistance)
            return maximumDistance
        }

        return radius
    }

    private func regionIdentifier(for id: UUID) -> String {
        regionIdentifierPrefix + id.uuidString
    }

    private func sendArrivalNotification(for region: CLRegion) {
        guard canSendArrivalNotification(for: region.identifier) else {
            print("Arrival notification already sent today for:", region.identifier)
            return
        }

        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                let content = UNMutableNotificationContent()
                content.title = "You are near your place"
                content.body = "Take a quiet moment and notice what is around you."
                content.sound = .default

                let request = UNNotificationRequest(
                    identifier: "arrival-notification-\(region.identifier)-\(UUID().uuidString)",
                    content: content,
                    trigger: nil
                )

                UNUserNotificationCenter.current().add(request) { error in
                    if let error {
                        print("Failed to send arrival notification:", error.localizedDescription)
                    } else {
                        self.markArrivalNotificationSent(for: region.identifier)
                        print("Arrival notification sent for:", region.identifier)
                    }
                }

            case .notDetermined:
                print("Notification permission not determined. Arrival notification was not sent.")

            case .denied:
                print("Notification permission denied. Arrival notification was not sent.")

            @unknown default:
                print("Unknown notification permission status. Arrival notification was not sent.")
            }
        }
    }

    private func canSendArrivalNotification(for regionIdentifier: String) -> Bool {
        let key = lastArrivalNotificationDateKey(for: regionIdentifier)

        guard let lastSentDate = UserDefaults.standard.object(forKey: key) as? Date else {
            return true
        }

        return !Calendar.current.isDateInToday(lastSentDate)
    }

    private func markArrivalNotificationSent(for regionIdentifier: String) {
        let key = lastArrivalNotificationDateKey(for: regionIdentifier)
        UserDefaults.standard.set(Date(), forKey: key)
    }

    private func lastArrivalNotificationDateKey(for regionIdentifier: String) -> String {
        "arrivalNotificationLastSentDate-\(regionIdentifier)"
    }
}
