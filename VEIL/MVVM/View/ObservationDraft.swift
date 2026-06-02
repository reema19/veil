//
//  ObservationDraft.swift
//  VEIL
//
//  Created by reema aljohani on 5/26/26.
//
import Foundation

struct ObservationDraft: Identifiable, Hashable {
    let id = UUID()

    let placeID: UUID
    let placeTitle: String
    let placeCurrentDay: Int
    let placeTotalDays: Int

    let sense: SenseType
    let prompt: String
    let durationSeconds: Int
}
