//
//  NameEntryView.swift
//  VEIL
//

import SwiftUI

struct NameEntryView: View {
    @Binding var name: String
    let onSubmit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            Text("What’s your name?")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color("TitleColor"))

            Text("Your display name for the app experience")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(Color("TitleColor").opacity(0.75))
                .lineLimit(1)

            HStack(spacing: 12) {
                TextField("", text: $name)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(Color("TitleColor"))
                    .padding(.horizontal, 12)
                    .frame(width:245,height: 48)
                    .background(
                        Capsule()
                            .fill(Color.white)
                    )
                    .overlay(
                        Capsule()
                            .stroke(Color("TitleColor"), lineWidth: 1)
                    )

                Button(action: onSubmit) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color.white)
                        .frame(width: 34, height: 34)
                        .background(
                            Circle()
                                .fill(Color(hex: "#212121"))
                        )
                }
            }
        }
        .frame(width: 310, alignment: .leading)
    }
}

#Preview {
    ZStack {
        Color("BackgroundColor")
            .ignoresSafeArea()

        NameEntryView(name: .constant("")) {}
    }
}
