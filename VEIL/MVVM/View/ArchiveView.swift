//
//  ArchiveView.swift
//  VEIL
//

import SwiftUI

struct ArchiveView: View {

    let places: [Place]
    let onProfileTap: () -> Void

    @State private var selectedIndex: Int = 0
    @State private var dragOffset: CGFloat = 0

    @State private var selectedPlaceForSheet: Place?

    private let cardWidth: CGFloat = 320
    private let cardHeight: CGFloat = 210

    private let verticalOffset: CGFloat = 190

    private var visiblePlaces: [Place] {
        Array(places.prefix(3))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // MARK: - Header
            HStack {
                Text("Your archive.")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color("TitleColor"))

                Spacer()

                Button(action: onProfileTap) {
                    Image(systemName: "person.crop.circle")
                        .font(.system(size: 27, weight: .medium))
                        .foregroundColor(.black)
                        .frame(width: 58, height: 58)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    Color.white.opacity(0.55),
                                    lineWidth: 1
                                )
                        )
                        .shadow(
                            color: .black.opacity(0.10),
                            radius: 14,
                            x: 0,
                            y: 8
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)

            if visiblePlaces.isEmpty {
                emptyArchiveView
            } else {
                verticalCarouselView
            }

            Spacer()
        }
        .sheet(item: $selectedPlaceForSheet) { place in
            ArchiveLockedSheet(
                place: place,
                onDone: {
                    selectedPlaceForSheet = nil
                }
            )
            .presentationDetents([.height(430)])
            .presentationDragIndicator(.hidden)
        }
    }

    // MARK: - Vertical Carousel
    private var verticalCarouselView: some View {
        ZStack {
            ForEach(visiblePlaces.indices, id: \.self) { index in

                Button {
                    selectedPlaceForSheet = visiblePlaces[index]
                } label: {
                    WatchingPlaceCardView(
                        place: visiblePlaces[index],
                        colorIndex: index
                    )
                    .frame(width: cardWidth, height: cardHeight)
                }
                .buttonStyle(.plain)
                .scaleEffect(scale(for: index))
                .opacity(opacity(for: index))
                .zIndex(zIndex(for: index))
                .offset(y: yOffset(for: index) + dragOffset)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 620)
        .contentShape(Rectangle())
        .clipped()
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation.height
                }
                .onEnded { value in
                    let threshold: CGFloat = 60

                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        if value.translation.height < -threshold {
                            moveToNextCard()
                        } else if value.translation.height > threshold {
                            moveToPreviousCard()
                        }

                        dragOffset = 0
                    }
                }
        )
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: selectedIndex)
        .animation(.spring(response: 0.25, dampingFraction: 0.9), value: dragOffset)
        .padding(.top, 20)
    }

    private func moveToNextCard() {
        guard !visiblePlaces.isEmpty else { return }
        selectedIndex = (selectedIndex + 1) % visiblePlaces.count
    }

    private func moveToPreviousCard() {
        guard !visiblePlaces.isEmpty else { return }
        selectedIndex = (selectedIndex - 1 + visiblePlaces.count) % visiblePlaces.count
    }

    private func circularPosition(for index: Int) -> Int {
        if index == selectedIndex {
            return 0
        }

        let previousIndex = (selectedIndex - 1 + visiblePlaces.count) % visiblePlaces.count
        let nextIndex = (selectedIndex + 1) % visiblePlaces.count

        if index == previousIndex {
            return -1
        }

        if index == nextIndex {
            return 1
        }

        return 2
    }

    private func yOffset(for index: Int) -> CGFloat {
        let position = circularPosition(for: index)

        switch position {
        case -1:
            return -verticalOffset
        case 0:
            return 0
        case 1:
            return verticalOffset
        default:
            return 0
        }
    }

    private func scale(for index: Int) -> CGFloat {
        let position = circularPosition(for: index)

        switch position {
        case 0:
            return 1.08
        case -1, 1:
            return 0.82
        default:
            return 0.82
        }
    }

    private func opacity(for index: Int) -> Double {
        let position = circularPosition(for: index)

        switch position {
        case 0:
            return 1.0
        case -1, 1:
            return 0.55
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

    // MARK: - Empty State
    private var emptyArchiveView: some View {
        VStack(spacing: 12) {
            Image(systemName: "archivebox")
                .font(.system(size: 34, weight: .regular))
                .foregroundColor(Color("SubtitleColor"))

            Text("No places yet")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color("TitleColor"))

            Text("Places you add will appear here.")
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(Color("SubtitleColor"))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 160)
    }
}

// MARK: - Locked Sheet

private struct ArchiveLockedSheet: View {

    let place: Place
    let onDone: () -> Void

    private var remainingDays: Int {
        let calendar = Calendar.current

        let today = calendar.startOfDay(for: Date())
        let endDate = calendar.startOfDay(for: place.activeEndDate)

        let days = calendar.dateComponents(
            [.day],
            from: today,
            to: endDate
        ).day ?? 0

        return max(days, 0)
    }

    private var openDateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: place.activeEndDate)
    }

    private var titleText: String {
        if remainingDays == 0 {
            return "Ready to open."
        } else if remainingDays == 1 {
            return "Sealed for 1 more day."
        } else {
            return "Sealed for \(remainingDays) more days."
        }
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {

            Color.white
                .ignoresSafeArea()

            Button(action: onDone) {
                Image(systemName: "xmark")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(Color(hex: "6F6F6F"))
                    .frame(width: 54, height: 54)
                    .background(.white)
                    .clipShape(Circle())
                    .shadow(
                        color: .black.opacity(0.08),
                        radius: 10,
                        x: 0,
                        y: 4
                    )
            }
            .padding(.top, 10)
            .padding(.trailing, 24)

            VStack(spacing: 0) {

                Spacer()
                    .frame(height: 78)

                ZStack {
                    Circle()
                        .fill(Color(red: 0.82, green: 0.88, blue: 0.82).opacity(0.45))
                        .frame(width: 72, height: 72)
                        .blur(radius: 6)

                    Image(systemName: "eye.slash")
                        .font(.system(size: 30, weight: .medium))
                        .foregroundColor(.black)
                }

                Text(titleText)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.top, 28)

                Text("Your photos and sounds remain hidden until\nthe period ends.")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color(hex: "6F6F6F"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .padding(.top, 20)

                HStack(spacing: 4) {
                    Text("Opens on")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(Color(hex: "252525"))

                    Text(openDateText)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(hex: "252525"))
                }
                .padding(.top, 28)

                Button(action: onDone) {
                    Text("Done")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 62)
                        .background(Color(hex: "252525"))
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 34)
                .padding(.top, 42)

                Spacer()
            }
        }
    }
}

#Preview {
    NavigationStack {
        ArchiveView(
            places: [],
            onProfileTap: {}
        )
    }
}
