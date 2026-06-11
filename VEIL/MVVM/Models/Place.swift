//
//  Place.swift
//  VEIL
//
//  Created by reema aljohani on 5/30/26.
//

import Foundation
import SwiftData

@Model
final class Place {
    var id: UUID
    var name: String
    var latitude: Double
    var longitude: Double
    var radiusMeters: Double
    var activeStartDate: Date
    var activeEndDate: Date
    var statusRawValue: String
    var createdAt: Date
    var deletedAt: Date?

    @Relationship(deleteRule: .cascade, inverse: \PlaceObservation.place)
    var observations: [PlaceObservation] = []

    init(
        id: UUID = UUID(),
        name: String,
        latitude: Double,
        longitude: Double,
        radiusMeters: Double = 1000,
        activeStartDate: Date = Date(),
        activeDays: Int
    ) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.radiusMeters = radiusMeters
        self.activeStartDate = activeStartDate
        self.activeEndDate = Calendar.current.date(
            byAdding: .day,
            value: activeDays,
            to: activeStartDate
        ) ?? activeStartDate
        self.statusRawValue = PlaceStatus.active.rawValue
        self.createdAt = Date()
        self.deletedAt = nil
    }

    var status: PlaceStatus {
        get { PlaceStatus(rawValue: statusRawValue) ?? .active }
        set { statusRawValue = newValue.rawValue }
    }

    var activeDays: Int {
        max(1, Calendar.current.dateComponents(
            [.day],
            from: activeStartDate,
            to: activeEndDate
        ).day ?? 1)
    }

    var currentDay: Int {
        let daysPassed = Calendar.current.dateComponents(
            [.day],
            from: activeStartDate,
            to: Date()
        ).day ?? 0

        return min(max(daysPassed + 1, 1), activeDays)
    }

    var totalPresenceSeconds: Int {
        observations.reduce(0) { $0 + $1.durationSeconds }
    }
}
