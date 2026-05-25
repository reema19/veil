//
//  StartButtonView.swift
//  VEIL
//
//  Created by Ghady Al Omar on 06/12/1447 AH.
//

import SwiftUI

struct StartButtonView: View {
    let action: () -> Void

    var body: some View {
        Button("Start", action: action)
            .font(.system(size: 17, weight: .bold))
            .foregroundColor(Color(hex: "#F8F8F8"))
            .kerning(-0.43)
            .frame(width: 160, height: 50)
            .background(
                Capsule()
                    .fill(Color(hex: "#212121"))
            )
    }
}
