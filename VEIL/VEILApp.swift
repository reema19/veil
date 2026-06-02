//
//  VEILApp.swift
//  VEIL
//
//  Created by reema aljohani on 5/23/26.
//

/*import SwiftUI

@main
struct VEILApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
*/

import SwiftUI
import SwiftData

@main
struct VEILApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            LocalProfile.self,
            Place.self,
            PlaceObservation.self
        ])
    }
}
