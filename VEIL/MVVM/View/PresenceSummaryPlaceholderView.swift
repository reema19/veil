//
//  PresenceSummaryPlaceholderView.swift
//  VEIL
//

import SwiftUI

struct PresenceSummaryPlaceholderView: View {

    let totalTime: String

    var body: some View {

        ZStack {

            PresenceBreathRing(size: 270)

            VStack(spacing: 4) {

                Text("total")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color("SubtitleColor"))

                Text(totalTime)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color("TitleColor"))

                Text("time present")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color("SubtitleColor"))
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 290)
    }
}
