//
//  MapRadiusControlView.swift
//  BePresent
//
//  Created by Rahaf Alhammadi on 25/11/1447 AH.
//

import SwiftUI
import CoreLocation

struct MapRadiusControlView: View {

    @Binding var radius: CLLocationDistance

    private let minimumRadius: CLLocationDistance = 1000
    private let maximumRadius: CLLocationDistance = 3000
    private let radiusStep: CLLocationDistance = 500

    var body: some View {

        HStack(spacing: 20) {

            Button(action: {
                if radius > minimumRadius {
                    radius -= radiusStep
                }
            }) {
                Image(systemName: "minus.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(radius > minimumRadius ? .blue : .gray)
            }
            .disabled(radius <= minimumRadius)

            Text(radiusText)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.gray)
                .frame(minWidth: 100)

            Button(action: {
                if radius < maximumRadius {
                    radius += radiusStep
                }
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(radius < maximumRadius ? .blue : .gray)
            }
            .disabled(radius >= maximumRadius)
        }
    }

    private var radiusText: String {
        if radius >= 1000 {
            return "\(Int(radius / 1000)) km radius"
        } else {
            return "\(Int(radius)) m radius"
        }
    }
}

#Preview {
    MapRadiusControlView(radius: .constant(1000))
}
