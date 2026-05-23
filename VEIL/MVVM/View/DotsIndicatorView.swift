//
//  DotsIndicatorView.swift
//  VEIL
//
//  Created by Ghady Al Omar on 06/12/1447 AH.
//



import SwiftUI

struct DotsIndicatorView: View {
    let totalPages: Int
    let currentIndex: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { i in
                Circle()
                    .fill(i == currentIndex ? Color("TitleColor") : Color("DotInactive"))
                    .frame(width: 8, height: 8)
            }
        }
    }
}
