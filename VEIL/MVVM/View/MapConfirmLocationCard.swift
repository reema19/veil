//
//  MapConfirmLocationCard.swift
//  BePresent
//
//  Created by Rahaf Alhammadi on 25/11/1447 AH.
//

import SwiftUI

struct MapConfirmLocationCard: View {

    let address: String
    let onConfirm: () -> Void

    var body: some View {

        VStack(spacing: 12) {

            // MARK: - Address Row
            HStack(alignment: .top, spacing: 8) {

                Image(systemName: "mappin")
                    .foregroundColor(.black)
                    .font(.system(size: 26))

                Text(address)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, -4)

            // MARK: - Confirm Button
            Button(action: onConfirm) {

                Text("Confirm Location")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.black)
                    .cornerRadius(20)
            }
        }
        .padding(20)
        .background(
            VisualEffectBlur(style: .systemMaterialLight)
                .clipShape(RoundedRectangle(cornerRadius: 24))
        )
        .transition(.move(edge: .bottom))
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.2).ignoresSafeArea()

        VStack {
            Spacer()

            MapConfirmLocationCard(
                address: "Riyadh, Saudi Arabia",
                onConfirm: {}
            )
            .padding(.horizontal, 28)
        }
    }
}
