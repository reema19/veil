//
//  PresenceSummaryPlaceholderView.swift
//  VEIL
//

import SwiftUI

struct PresenceSummaryPlaceholderView: View {

    let totalTime: String

    var body: some View {
        ZStack {

            Circle()
                .stroke(
                    Color(red: 0.95, green: 0.92, blue: 0.45).opacity(0.45),
                    style: StrokeStyle(
                        lineWidth: 1,
                        lineCap: .round,
                        dash: [1, 10]
                    )
                )
                .frame(width: 300, height: 300)

            Circle()
                .fill(Color(red: 0.82, green: 0.88, blue: 0.82).opacity(0.18))
                .frame(width: 230, height: 230)

            Circle()
                .stroke(
                    Color("TitleColor").opacity(0.04),
                    lineWidth: 18
                )
                .frame(width: 210, height: 210)

            Circle()
                .fill(Color(red: 0.97, green: 0.97, blue: 0.85))
                .frame(width: 120, height: 120)

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
        .frame(height: 310)
    }
}
