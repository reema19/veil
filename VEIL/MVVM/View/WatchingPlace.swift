//
//  WatchingPlace.swift
//  VEIL
//

import SwiftUI

struct WatchingPlace: Identifiable {
    let id = UUID()
    let title: String
    let currentDay: Int
    let totalDays: Int
    let tint: Color
}
