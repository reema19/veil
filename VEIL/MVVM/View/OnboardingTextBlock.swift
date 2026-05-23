//
//  OnboardingTextBlock.swift
//  VEIL
//
//  Created by Ghady Al Omar on 06/12/1447 AH.
//

//
//  OnboardingTextBlock.swift
//  ghady
//

import SwiftUI

struct OnboardingTextBlock: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 38, weight: .bold))
                .foregroundColor(Color("TitleColor"))
            Text(subtitle)
                .font(.system(size: 18).italic())
                .foregroundColor(Color("SubtitleColor"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 32)
    }
}
