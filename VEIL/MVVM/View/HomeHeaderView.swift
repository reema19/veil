//
//  HomeHeaderView.swift
//  VEIL
//

import SwiftUI

struct HomeHeaderView: View {

    let userName: String
    var onProfileTap: () -> Void

    var body: some View {
        HStack(alignment: .center) {

            Text("Good morning, \(userName)")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color("TitleColor"))

            Spacer()

            Button(action: onProfileTap) {
                Image(systemName: "person.crop.circle")
                    .font(.system(size: 23, weight: .medium))
                    .foregroundColor(Color("TitleColor"))
                    .frame(width: 58, height: 58)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .strokeBorder(
                                Color("TitleColor").opacity(0.08),
                                lineWidth: 1
                            )
                    )
                    .shadow(
                        color: .black.opacity(0.08),
                        radius: 12,
                        x: 0,
                        y: 6
                    )
            }
        }
    }
}
