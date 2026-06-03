//
//  ZoomLevel.swift
//  VEIL
//
//  Created by Ghady Al Omar on 07/12/1447 AH.
//

import Foundation
import CoreGraphics

enum ZoomLevel: String, CaseIterable {
    case half = ".5"
    case one = "1x"
    case three = "3"

    var factor: CGFloat {
        switch self {
        case .half:
            return 0.5
        case .one:
            return 1.0
        case .three:
            return 3.0
        }
    }
}
