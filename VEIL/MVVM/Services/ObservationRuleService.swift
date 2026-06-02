//
//  ObservationRuleService.swift
//  VEIL
//
//  Created by reema aljohani on 5/30/26.
//

import Foundation

final class ObservationRuleService {

    func canAddObservation(
        to place: Place,
        sense: SenseType,
        on date: Date = Date()
    ) -> Bool {
        guard place.status == .active else { return false }

        let calendar = Calendar.current

        let alreadyAddedToday = place.observations.contains { observation in
            observation.sense == sense &&
            calendar.isDate(observation.createdAt, inSameDayAs: date)
        }

        return !alreadyAddedToday
    }
}
