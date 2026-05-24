//
//  HomeViewModel.swift
//  VEIL
//

import SwiftUI
import Combine

final class HomeViewModel: ObservableObject {

    @AppStorage("user_name") private var savedUserName: String = ""

    var userName: String {
        savedUserName.isEmpty ? "there" : savedUserName
    }
    @Published var totalPresenceTime: String = "00:00:00"

    @Published var places: [WatchingPlace] = [
        WatchingPlace(
            title: "Morning café",
            currentDay: 1,
            totalDays: 7,
            tint: Color(red: 0.93, green: 0.92, blue: 0.58)
        ),
        WatchingPlace(
            title: "University",
            currentDay: 2,
            totalDays: 7,
            tint: Color(red: 0.82, green: 0.88, blue: 0.82)
        ),
        WatchingPlace(
            title: "Home",
            currentDay: 4,
            totalDays: 7,
            tint: Color(red: 0.83, green: 0.86, blue: 0.92)
        )
    ]
}
