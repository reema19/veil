//
//  HomeViewModel.swift
//  VEIL
//

/*import SwiftUI
import Combine

final class HomeViewModel: ObservableObject {

    @AppStorage("user_name") private var savedUserName: String = ""

    var userName: String {
        savedUserName.isEmpty ? "there" : savedUserName
    }

    @Published var totalPresenceTime: String = "00:00:00"

    @Published var places: [WatchingPlace] = []

    init() {
        loadSavedPlaces()
    }

    // MARK: - Add Place

    func addPlace(title: String, totalDays: Int) {

        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedTitle.isEmpty else { return }

        // Only 3 folders per user
        guard places.count < 3 else { return }

        let newPlace = WatchingPlace(
            title: trimmedTitle,
            currentDay: 1,
            totalDays: totalDays,
            tint: tintForPlace(index: places.count)
        )

        places.append(newPlace)
        savePlaces()
    }

    // MARK: - Load Places

    func loadSavedPlaces() {

        guard let data = UserDefaults.standard.data(forKey: "saved_places") else {
            places = []
            return
        }

        do {
            let savedPlaces = try JSONDecoder().decode([SavedWatchingPlace].self, from: data)

            places = savedPlaces.enumerated().map { index, savedPlace in
                WatchingPlace(
                    title: savedPlace.title,
                    currentDay: savedPlace.currentDay,
                    totalDays: savedPlace.totalDays,
                    tint: tintForPlace(index: index)
                )
            }

        } catch {
            print("Failed to load saved places:", error)
            places = []
        }
    }

    // MARK: - Save Places

    private func savePlaces() {

        let savedPlaces = places.map { place in
            SavedWatchingPlace(
                title: place.title,
                currentDay: place.currentDay,
                totalDays: place.totalDays
            )
        }

        do {
            let data = try JSONEncoder().encode(savedPlaces)
            UserDefaults.standard.set(data, forKey: "saved_places")
        } catch {
            print("Failed to save places:", error)
        }
    }

    // MARK: - Folder Colors

    private func tintForPlace(index: Int) -> Color {

        switch index {
        case 0:
            // First folder = yellow
            return Color(red: 0.93, green: 0.92, blue: 0.58)

        case 1:
            // Second folder = green
            return Color(red: 0.82, green: 0.88, blue: 0.82)

        case 2:
            // Third folder = blue
            return Color(red: 0.83, green: 0.86, blue: 0.92)

        default:
            return Color(red: 0.93, green: 0.92, blue: 0.58)
        }
    }
}

// MARK: - Saved Model

private struct SavedWatchingPlace: Codable {
    let title: String
    let currentDay: Int
    let totalDays: Int
}*/

