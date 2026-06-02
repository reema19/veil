//
//  PlaceObservation.swift
//  VEIL
//
//  Created by reema aljohani on 5/30/26.
//

import Foundation
import SwiftData

@Model
final class PlaceObservation {
    var id: UUID

    var senseRawValue: String
    var promptText: String

    var mediaFileName: String
    var durationSeconds: Int

    var createdAt: Date

    var place: Place?

    init(
        id: UUID = UUID(),
        sense: SenseType,
        promptText: String,
        mediaFileName: String,
        durationSeconds: Int,
        createdAt: Date = Date(),
        place: Place
    ) {
        self.id = id
        self.senseRawValue = sense.rawValue
        self.promptText = promptText
        self.mediaFileName = mediaFileName
        self.durationSeconds = durationSeconds
        self.createdAt = createdAt
        self.place = place
    }

    var sense: SenseType {
        get {
            SenseType(rawValue: senseRawValue) ?? .sight
        }
        set {
            senseRawValue = newValue.rawValue
        }
    }
}
