//
//  WatchingPlacesSectionView.swift
//  VEIL
//

import SwiftUI

struct WatchingPlacesSectionView: View {

    let places: [WatchingPlace]
    var onAddPlaceTap: () -> Void

    @State private var selectedIndex: Int = 0
    @State private var dragOffset: CGFloat = 0

    private let cardWidth: CGFloat = 320
    private let cardHeight: CGFloat = 210

    // Change this number if you want the side cards to show more or less.
    // Smaller = more of the side cards visible.
    // Bigger = less of the side cards visible.
    private let sideOffset: CGFloat = 260

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {

            HStack(alignment: .center) {

                VStack(alignment: .leading, spacing: 8) {
                    Text("Places you're watching")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color("TitleColor"))

                    Text("Slowly noticing what surrounds you.")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Color("SubtitleColor"))
                }

                Spacer()

                Button(action: onAddPlaceTap) {
                    Image(systemName: "plus")
                        .font(.system(size: 27, weight: .bold))
                        .foregroundColor(.black)
                        .frame(width: 50, height: 50)
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
                            color: .black.opacity(0.14),
                            radius: 8,
                            x: 0,
                            y: 4
                        )
                }
            }

            if places.isEmpty {
                EmptyView()
            } else {
                carouselView
            }
        }
    }

    private var carouselView: some View {
        ZStack {
            ForEach(places.indices, id: \.self) { index in
                WatchingPlaceCardView(place: places[index])
                    .frame(width: cardWidth, height: cardHeight)
                    .scaleEffect(scale(for: index))
                    .opacity(opacity(for: index))
                    .zIndex(zIndex(for: index))
                    .offset(x: xOffset(for: index) + dragOffset)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: cardHeight + 20)
        .contentShape(Rectangle())
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation.width
                }
                .onEnded { value in
                    let threshold: CGFloat = 60

                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        if value.translation.width < -threshold {
                            moveToNextCard()
                        } else if value.translation.width > threshold {
                            moveToPreviousCard()
                        }

                        dragOffset = 0
                    }
                }
        )
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: selectedIndex)
        .animation(.spring(response: 0.25, dampingFraction: 0.9), value: dragOffset)
    }

    private func moveToNextCard() {
        selectedIndex = (selectedIndex + 1) % places.count
    }

    private func moveToPreviousCard() {
        selectedIndex = (selectedIndex - 1 + places.count) % places.count
    }

    private func circularPosition(for index: Int) -> Int {
        if index == selectedIndex {
            return 0
        }

        let previousIndex = (selectedIndex - 1 + places.count) % places.count
        let nextIndex = (selectedIndex + 1) % places.count

        if index == previousIndex {
            return -1
        }

        if index == nextIndex {
            return 1
        }

        return 2
    }

    private func xOffset(for index: Int) -> CGFloat {
        let position = circularPosition(for: index)

        switch position {
        case -1:
            return -sideOffset
        case 0:
            return 0
        case 1:
            return sideOffset
        default:
            return 0
        }
    }

    private func scale(for index: Int) -> CGFloat {
        let position = circularPosition(for: index)

        switch position {
        case 0:
            return 1.08      // center card bigger

        case -1, 1:
            return 0.82      // side cards smaller

        default:
            return 0.82
        }
    }

    private func opacity(for index: Int) -> Double {
        let position = circularPosition(for: index)

        switch position {
        case 0:
            return 1.0       // center card fully visible

        case -1, 1:
            return 0.55      // side cards lighter

        default:
            return 0
        }
    }

    private func zIndex(for index: Int) -> Double {
        let position = circularPosition(for: index)

        switch position {
        case 0:
            return 3
        case -1, 1:
            return 2
        default:
            return 0
        }
    }
}
