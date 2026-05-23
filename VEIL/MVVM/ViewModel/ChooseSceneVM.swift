//
//  ChooseSceneVM.swift
//  VEIL
//
//  Created by Ghady Al Omar on 06/12/1447 AH.
//


import Foundation
import Combine

final class ChooseSceneViewModel: ObservableObject {
    let sceneTitle: String = "Morning café"
    let senses: [SenseType] = SenseType.allCases

    func didSelect(sense: SenseType) {
        print("Selected: \(sense.title)")
    }
}
