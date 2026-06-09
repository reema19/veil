//
//  ArchiveView.swift
//  VEIL
//

import SwiftUI

struct ArchiveView: View {

    let places: [Place]
    let onProfileTap: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @State private var selectedIndex: Int = 0
    @State private var dragOffset: CGFloat = 0

    @State private var selectedPlaceForSheet: Place?
    @State private var selectedPlaceForRecap: Place?

    private let cardHeight: CGFloat = 210
    private let verticalOffset: CGFloat = 190

    private var visiblePlaces: [Place] {
        Array(places.prefix(3))
    }

    private var isAccessibilitySize: Bool {
        dynamicTypeSize.isAccessibilitySize
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: isAccessibilitySize ? 32 : 26) {

                    archiveHeader

                    if visiblePlaces.isEmpty {
                        emptyStateContainer(screenHeight: geometry.size.height)
                    } else {
                        verticalCarouselView(screenWidth: geometry.size.width)
                    }
                }
                .padding(.horizontal, responsiveHorizontalPadding(for: geometry.size.width))
                .padding(.top, 20)
                .padding(.bottom, 110)
            }
            .background(Color("BackgroundColor").ignoresSafeArea())
        }
        .sheet(item: $selectedPlaceForSheet) { place in
            ArchiveLockedSheet(
                place: place,
                onDone: {
                    selectedPlaceForSheet = nil
                }
            )
            .presentationDetents([.height(isAccessibilitySize ? 560 : 430)])
            .presentationDragIndicator(.hidden)
        }
        .fullScreenCover(item: $selectedPlaceForRecap) { place in
            RealRecapSandboxView(place: place)
        }
    }

    private var archiveHeader: some View {
        HStack(alignment: .center, spacing: 16) {
            Text("Your archive")
                .font(.custom("DMSans-Bold", size: 24, relativeTo: .title2))
                .foregroundColor(Color("TitleColor"))
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)

            Button(action: onProfileTap) {
                Image(systemName: "person.crop.circle")
                    .font(.system(size: 23, weight: .medium))
                    .foregroundColor(Color("TitleColor"))
                    .frame(width: isAccessibilitySize ? 62 : 58, height: isAccessibilitySize ? 62 : 58)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .strokeBorder(Color("TitleColor").opacity(0.08), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open profile")
        }
        .frame(maxWidth: .infinity)
    }

    private func emptyStateContainer(screenHeight: CGFloat) -> some View {
        VStack {
            Spacer(minLength: 0)
            emptyArchiveView
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, minHeight: screenHeight * 0.65)
    }

    private var emptyArchiveView: some View {
        VStack(spacing: 12) {
            Image(systemName: "archivebox")
                .font(.system(size: 34, weight: .regular))
                .foregroundColor(Color("SubtitleColor"))
                .accessibilityHidden(true)

            Text("No places yet")
                .font(.custom("DMSans-SemiBold", size: 18, relativeTo: .headline))
                .foregroundColor(Color("TitleColor"))
                .multilineTextAlignment(.center)

            Text("Places you add will appear here.")
                .font(.custom("DMSans-Regular", size: 13, relativeTo: .body))
                .foregroundColor(Color("SubtitleColor"))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .accessibilityElement(children: .combine)
    }

    private func verticalCarouselView(screenWidth: CGFloat) -> some View {
        let width = responsiveCardWidth(for: screenWidth)
        let height = isAccessibilitySize ? cardHeight + 44 : cardHeight
        let carouselHeight: CGFloat = isAccessibilitySize ? 720 : 620

        return ZStack {
            ForEach(visiblePlaces.indices, id: \.self) { index in
                let place = visiblePlaces[index]

                WatchingPlaceCardView(
                    place: place,
                    colorIndex: index
                )
                .frame(width: width, height: height)
                .contentShape(Rectangle())
                .onTapGesture {
                    handlePlaceTap(place)
                }
                .highPriorityGesture(cardSwipeGesture)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(place.name)")
                .scaleEffect(scale(for: index))
                .opacity(opacity(for: index))
                .zIndex(zIndex(for: index))
                .offset(y: yOffset(for: index) + dragOffset)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: carouselHeight)
        .contentShape(Rectangle())
        .clipped()
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: selectedIndex)
        .animation(.spring(response: 0.25, dampingFraction: 0.9), value: dragOffset)
        .padding(.top, 4)
    }

    private var cardSwipeGesture: some Gesture {
        DragGesture(minimumDistance: 8)
            .onChanged { value in
                dragOffset = value.translation.height
            }
            .onEnded { value in
                let threshold: CGFloat = 65

                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    if value.translation.height < -threshold {
                        moveToNextCard()
                    } else if value.translation.height > threshold {
                        moveToPreviousCard()
                    }

                    dragOffset = 0
                }
            }
    }

    private func handlePlaceTap(_ place: Place) {
        #if DEBUG
        selectedPlaceForRecap = place
        #else
        if Date() >= place.activeEndDate {
            selectedPlaceForRecap = place
        } else {
            selectedPlaceForSheet = place
        }
        #endif
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
        if index == selectedIndex { return 0 }

        let previousIndex = (selectedIndex - 1 + visiblePlaces.count) % visiblePlaces.count
        let nextIndex = (selectedIndex + 1) % visiblePlaces.count

        if index == previousIndex { return -1 }
        if index == nextIndex { return 1 }

        return 2
    }

    private func yOffset(for index: Int) -> CGFloat {
        switch circularPosition(for: index) {
        case -1:
            return isAccessibilitySize ? -220 : -verticalOffset
        case 0:
            return 0
        case 1:
            return isAccessibilitySize ? 220 : verticalOffset
        default:
            return 0
        }
    }

    private func scale(for index: Int) -> CGFloat {
        switch circularPosition(for: index) {
        case 0:
            return isAccessibilitySize ? 1.0 : 1.08
        case -1, 1:
            return isAccessibilitySize ? 0.86 : 0.82
        default:
            return 0.82
        }
    }

    private func opacity(for index: Int) -> Double {
        switch circularPosition(for: index) {
        case 0:
            return 1.0
        case -1, 1:
            return 0.55
        default:
            return 0
        }
    }

    private func zIndex(for index: Int) -> Double {
        switch circularPosition(for: index) {
        case 0:
            return 3
        case -1, 1:
            return 2
        default:
            return 0
        }
    }

    private func responsiveHorizontalPadding(for width: CGFloat) -> CGFloat {
        width < 380 ? 18 : 24
    }

    private func responsiveCardWidth(for screenWidth: CGFloat) -> CGFloat {
        let horizontalPadding = responsiveHorizontalPadding(for: screenWidth) * 2
        let availableWidth = screenWidth - horizontalPadding
        return min(320, availableWidth)
    }
}

// MARK: - Locked Sheet

private struct ArchiveLockedSheet: View {

    let place: Place
    let onDone: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var isAccessibilitySize: Bool {
        dynamicTypeSize.isAccessibilitySize
    }

    private var remainingDays: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let endDate = calendar.startOfDay(for: place.activeEndDate)

        let days = calendar.dateComponents([.day], from: today, to: endDate).day ?? 0
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
            Color.white.ignoresSafeArea()

            Button(action: onDone) {
                Image(systemName: "xmark")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(Color(hex: "6F6F6F"))
                    .frame(width: 54, height: 54)
                    .background(.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
            }
            .padding(.top, 10)
            .padding(.trailing, 24)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer().frame(height: isAccessibilitySize ? 70 : 78)

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
                        .font(.custom("DMSans-Bold", size: 24, relativeTo: .title2))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding(.top, 28)
                        .padding(.horizontal, 28)

                    Text("Your photos and sounds remain hidden until the period ends.")
                        .font(.custom("DMSans-Regular", size: 16, relativeTo: .body))
                        .foregroundColor(Color(hex: "6F6F6F"))
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .padding(.top, 20)
                        .padding(.horizontal, 34)

                    VStack(spacing: 4) {
                        Text("Opens on")
                            .font(.custom("DMSans-Regular", size: 18, relativeTo: .body))
                            .foregroundColor(Color(hex: "252525"))

                        Text(openDateText)
                            .font(.custom("DMSans-Bold", size: 18, relativeTo: .headline))
                            .foregroundColor(Color(hex: "252525"))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 28)

                    Button(action: onDone) {
                        Text("Done")
                            .font(.custom("DMSans-SemiBold", size: 16, relativeTo: .headline))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 62)
                            .background(Color(hex: "252525"))
                            .clipShape(Capsule())
                    }
                    .padding(.horizontal, 34)
                    .padding(.top, 42)

                    Spacer().frame(height: 32)
                }
                .frame(maxWidth: .infinity)
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
