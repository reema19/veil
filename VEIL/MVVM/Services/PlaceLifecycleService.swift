//
//  PlaceLifecycleService.swift
//  VEIL
//
//  Created by reema aljohani on 5/30/26.
//

import Foundation
import SwiftData

final class PlaceLifecycleService {

    func updateExpiredPlaces(_ places: [Place], context: ModelContext) {
        let now = Date()
        var didUpdate = false

        for place in places {
            guard place.status == .active else { continue }

            if now >= place.activeEndDate {
                place.status = .archived
                didUpdate = true
            }
        }

        guard didUpdate else { return }

        do {
            try context.save()
        } catch {
            print("Failed to update expired places:", error)
        }
    }
}
