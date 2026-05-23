//
//  Sense.swift
//  VEIL
//
//  Created by Ghady Al Omar on 06/12/1447 AH.
//
import Foundation

enum SenseType: CaseIterable {
    case sight
    case sound

    var icon: String {
        switch self {
        case .sight: return "eye"
        case .sound: return "ear.badge.waveform"
        }
    }

    var title: String {
        switch self {
        case .sight: return "Sight"
        case .sound: return "Sound"
        }
    }

    var description: String {
        switch self {
        case .sight: return "Capture a photo of what stands out in this place."
        case .sound: return "Record the ambient sound that shapes the atmosphere."
        }
    }

    var colorName: String {
        switch self {
        case .sight: return "sightcolor"
        case .sound: return "soundcolor"
        }
    }
}
