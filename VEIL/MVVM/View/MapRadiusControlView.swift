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

    var body: some View {

        HStack(spacing: 20) {

            Button(action: {
                if radius > 1000 {
                    radius -= 500
                }
            }) {
                Image(systemName: "minus.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.blue)
            }

            Text("\(Int(radius / 1000)) km radius")
                .font(.system(size: 16))
                .foregroundColor(.gray)

            Button(action: {
                if radius < 5000 {
                    radius += 500
                }
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.blue)
            }
        }
    }
}

#Preview {
    MapRadiusControlView(radius: .constant(1000))
}
