//
//  SenseSelectionView.swift
//  VEIL
//

import SwiftUI

struct SenseSelectionView: View {

    let place: WatchingPlace

    @Environment(\.dismiss) private var dismiss

    var body: some View {

        ZStack {

            Color("BackgroundColor")
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {

                // MARK: - Top Bar
                HStack(spacing: 12) {

                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(.black)
                            .frame(width: 50, height: 50)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .shadow(
                                color: .black.opacity(0.08),
                                radius: 12,
                                x: 0,
                                y: 6
                            )
                    }

                    Text(place.title)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color("TitleColor"))
                        .lineLimit(1)

                    Spacer()
                }
                .padding(.horizontal, 18)
                .padding(.top, 20)

                // MARK: - Question
                Text("which sense will guide you\ntoday ?")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color("TitleColor"))
                    .lineSpacing(1)
                    .padding(.horizontal, 42)
                    .padding(.top, 52)

                // MARK: - Cards
                VStack(spacing: 46) {

                    NavigationLink {
                        sightquestions(place: place)
                    } label: {
                        SenseCardView(sense: .sight)
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        soundquestions(place: place)
                    } label: {
                        SenseCardView(sense: .sound)
                    }
                    .buttonStyle(.plain)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 58)

                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationStack {
        SenseSelectionView(
            place: WatchingPlace(
                title: "Morning café",
                currentDay: 1,
                totalDays: 7,
                tint: Color(red: 0.93, green: 0.92, blue: 0.58)
            )
        )
    }
}
