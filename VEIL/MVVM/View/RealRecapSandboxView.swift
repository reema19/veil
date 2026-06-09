//
//  RealRecapSandboxView.swift
//  VEIL
//
//  Created by reema aljohani on 6/6/26.
//


import SwiftUI
import AVFoundation

struct RealRecapSandboxView: View {

    @Environment(\.dismiss) private var dismiss
    let place: Place

    @State private var pageIndex = 0

    private var observations: [PlaceObservation] {
        place.observations.sorted { $0.createdAt < $1.createdAt }
    }

    private var totalPages: Int {
        observations.count + 2
    }

    private var currentObservation: PlaceObservation? {
        guard pageIndex > 0, pageIndex < totalPages - 1 else { return nil }
        return observations[pageIndex - 1]
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundView(size: geometry.size)

                if pageIndex == 0 {
                    introView(size: geometry.size)
                } else if pageIndex == totalPages - 1 {
                    summaryView(size: geometry.size)
                } else if let observation = currentObservation {
                    switch observation.sense {
                    case .sight:
                        photoView(observation, size: geometry.size)
                    case .sound:
                        audioView(observation, size: geometry.size)
                    }
                }

                fixedTopBar(size: geometry.size)

                storyNavigationLayer(size: geometry.size)
            }
            .ignoresSafeArea()
            .gesture(
                DragGesture(minimumDistance: 24)
                    .onEnded { value in
                        if value.translation.height > 90 {
                            dismiss()
                        }
                    }
            )
        }
    }

    @ViewBuilder
    private func backgroundView(size: CGSize) -> some View {
        if let observation = currentObservation,
           observation.sense == .sight,
           let image = MediaStorageService.shared.loadPhoto(fileName: observation.mediaFileName) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: size.width, height: size.height)
                .clipped()
        } else {
            recapSoftBackground
        }
    }

    private func fixedTopBar(size: CGSize) -> some View {
        VStack(spacing: 0) {
            RecapProgressBar(
                currentIndex: pageIndex,
                total: totalPages,
                activeColor: progressColor
            )
            .padding(.horizontal, 24)
            .padding(.top, 88)

            Spacer()
        }
    }

    private var progressColor: Color {
        guard let observation = currentObservation else {
            return Color(hex: "252525")
        }

        switch observation.sense {
        case .sight:
            return .white
        case .sound:
            return Color(hex: "EFF0A3")
        }
    }

    private func introView(size: CGSize) -> some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 0) {
                Text("YOUR")
                    .font(.custom("DMSans-Bold", size: 12))
                    .foregroundColor(Color(hex: "9DB791"))

                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("\(place.activeDays)")
                    Text(place.activeDays == 1 ? "day" : "days")
                        .italic()
                }
                .font(.system(size: 54, weight: .light, design: .serif))
                .foregroundColor(Color(hex: "252525"))
                .padding(.top, 18)

                Text("at \(place.name)")
                    .font(.system(size: 17, weight: .regular, design: .serif))
                    .italic()
                    .foregroundColor(Color(hex: "252525"))
                    .padding(.top, 8)
            }

            Spacer()

            Text("tap to continue")
                .font(.custom("DMSans-Regular", size: 13))
                .foregroundColor(Color(hex: "6F6F6F"))
                .padding(.bottom, 76)
        }
        .frame(width: size.width, height: size.height)
    }

    private func photoView(_ observation: PlaceObservation, size: CGSize) -> some View {
        ZStack {
            bottomGradient

            VStack(alignment: .leading, spacing: 0) {
                headerText(
                    placeName: place.name,
                    date: observation.createdAt,
                    color: .white
                )

                Spacer()

                promptText(observation.promptText)
            }
            .padding(.horizontal, 28)
            .padding(.top, 118)
            .padding(.bottom, 58)
        }
        .frame(width: size.width, height: size.height)
    }

    private func audioView(_ observation: PlaceObservation, size: CGSize) -> some View {
        ZStack {
            bottomGradient

            VStack(alignment: .leading, spacing: 0) {
                headerText(
                    placeName: place.name,
                    date: observation.createdAt,
                    color: Color(hex: "252525")
                )

                Spacer(minLength: 0)

                RealRecapAudioPlayer(
                    observation: observation,
                    availableWidth: size.width
                )
                .padding(.top, 18)

                Spacer(minLength: 0)

                promptText(observation.promptText)
            }
            .padding(.horizontal, 28)
            .padding(.top, 118)
            .padding(.bottom, 58)
        }
        .frame(width: size.width, height: size.height)
    }

    private func summaryView(size: CGSize) -> some View {
        VStack(spacing: 0) {
            Spacer()

            Text("YOU WERE PRESENT FOR")
                .font(.custom("DMSans-Bold", size: 12))
                .foregroundColor(Color(hex: "6F6F6F"))

            Text(formatDuration(place.totalPresenceSeconds))
                .font(.system(size: 54, weight: .light, design: .serif))
                .italic()
                .foregroundColor(Color(hex: "252525"))
                .padding(.top, 22)

            Text("at \(place.name).")
                .font(.system(size: 17, weight: .regular, design: .serif))
                .italic()
                .foregroundColor(Color(hex: "6F6F6F"))
                .padding(.top, 22)

            Spacer()

            Text("View all moments")
                .font(.custom("DMSans-Regular", size: 13))
                .foregroundColor(.white.opacity(0.8))
                .padding(.bottom, 76)
        }
        .frame(width: size.width, height: size.height)
    }

    private func headerText(placeName: String, date: Date, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("at \(placeName)")
                .font(.system(size: 18, weight: .regular, design: .serif))
                .foregroundColor(color)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text(formatDate(date))
                .font(.custom("DMSans-Regular", size: 14))
                .foregroundColor(color.opacity(0.92))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func promptText(_ text: String) -> some View {
        Text("“\(text)”")
            .font(.custom("DMSans-Bold", size: 26))
            .foregroundColor(.white)
            .lineSpacing(5)
            .multilineTextAlignment(.leading)
            .lineLimit(4)
            .minimumScaleFactor(0.72)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var bottomGradient: some View {
        VStack {
            Spacer()

            LinearGradient(
                colors: [
                    Color.black.opacity(0.0),
                    Color.black.opacity(0.20),
                    Color.black.opacity(0.58)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 360)
        }
    }

    private func storyNavigationLayer(size: CGSize) -> some View {
        HStack(spacing: 0) {

            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    goBack()
                }

            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    goForward()
                }
        }
        .frame(width: size.width, height: size.height * 0.58)
        .position(x: size.width / 2, y: size.height * 0.42)
        .allowsHitTesting(true)
    }

    private func goForward() {
        if pageIndex < totalPages - 1 {
            pageIndex += 1
        } else {
            dismiss()
        }
    }

    private func goBack() {
        if pageIndex > 0 {
            pageIndex -= 1
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter.string(from: date)
    }

    private func formatDuration(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}

// MARK: - Audio Player

private struct RealRecapAudioPlayer: View {

    let observation: PlaceObservation
    let availableWidth: CGFloat

    @State private var player: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var needleIsDown = false
    @State private var progress: Double = 0
    @State private var duration: TimeInterval = 0
    @State private var timer: Timer?
    @State private var recordRotation: Double = 0

    private var recordSize: CGFloat {
        min(availableWidth * 0.68, 270)
    }

    var body: some View {
        VStack(spacing: 28) {
            VinylRecordView(
                rotation: recordRotation,
                isPlaying: isPlaying,
                needleIsDown: needleIsDown,
                onNeedleChanged: { isDown in
                    needleIsDown = isDown
                    isDown ? playAudio() : pauseAudio()
                }
            )
            .frame(width: recordSize, height: recordSize)

            VStack(spacing: 14) {
                Slider(
                    value: $progress,
                    in: 0...1,
                    onEditingChanged: { editing in
                        if !editing {
                            seekAudio()
                        }
                    }
                )
                .tint(Color(hex: "EFF0A3"))

                HStack {
                    Text(formatTime(currentTime))

                    Spacer()

                    Button {
                        needleIsDown.toggle()
                        needleIsDown ? playAudio() : pauseAudio()
                    } label: {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 27, weight: .bold))
                            .foregroundColor(.black)
                            .frame(width: 52, height: 52)
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Text(formatTime(duration))
                }
                .font(.custom("DMSans-Regular", size: 20))
                .foregroundColor(Color(hex: "252525"))
            }
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            prepareAudio()
        }
        .onDisappear {
            stopAudio()
        }
    }

    private var currentTime: TimeInterval {
        guard duration > 0 else { return 0 }
        return progress * duration
    }

    private func prepareAudio() {
        guard player == nil else { return }

        let url = MediaStorageService.shared.audioURL(fileName: observation.mediaFileName)

        guard FileManager.default.fileExists(atPath: url.path) else { return }

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)

            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            duration = player?.duration ?? 0
        } catch {
            print("Audio error:", error.localizedDescription)
        }
    }

    private func playAudio() {
        prepareAudio()
        player?.play()
        isPlaying = true
        startTimer()
    }

    private func pauseAudio() {
        player?.pause()
        isPlaying = false
    }

    private func stopAudio() {
        player?.stop()
        player = nil
        isPlaying = false
        progress = 0
        timer?.invalidate()
        timer = nil
    }

    private func seekAudio() {
        guard let player else { return }
        player.currentTime = progress * player.duration
    }

    private func startTimer() {
        timer?.invalidate()

        timer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { _ in
            guard let player else { return }

            if player.duration > 0 {
                progress = player.currentTime / player.duration
                duration = player.duration
            }

            if player.isPlaying {
                recordRotation += 2.4
            } else {
                isPlaying = false
            }

            if player.currentTime >= player.duration {
                isPlaying = false
                needleIsDown = false
                timer?.invalidate()
                timer = nil
            }
        }
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let totalSeconds = max(Int(time), 0)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Vinyl

private struct VinylRecordView: View {

    let rotation: Double
    let isPlaying: Bool
    let needleIsDown: Bool
    let onNeedleChanged: (Bool) -> Void

    var body: some View {
        ZStack {
            recordBody
                .rotationEffect(.degrees(rotation))

            needle
                .offset(x: 74, y: -78)
        }
    }

    private var recordBody: some View {
        ZStack {
            Circle()
                .fill(Color(hex: "111111"))

            ForEach(0..<12, id: \.self) { index in
                Circle()
                    .stroke(Color.white.opacity(0.045), lineWidth: 2)
                    .padding(CGFloat(index) * 10)
            }

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "1A1A1A"),
                            Color(hex: "EFF0A3").opacity(0.95),
                            Color(hex: "EFF0A3").opacity(0.52),
                            Color(hex: "111111")
                        ],
                        center: .center,
                        startRadius: 4,
                        endRadius: 78
                    )
                )
                .frame(width: 112, height: 112)

            Circle()
                .fill(Color(hex: "242424"))
                .frame(width: 20, height: 20)

            Circle()
                .fill(Color.white.opacity(0.20))
                .frame(width: 7, height: 7)
                .offset(x: -52, y: -70)
        }
    }

    private var needle: some View {
        ZStack {
            Capsule()
                .fill(Color(hex: "D2D2D2"))
                .frame(width: 108, height: 12)
                .rotationEffect(.degrees(needleIsDown ? -42 : -28))
                .offset(x: needleIsDown ? -8 : 6, y: needleIsDown ? 28 : 10)

            Circle()
                .fill(Color(hex: "BDBDBD"))
                .frame(width: 38, height: 38)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.5), lineWidth: 3)
                )
                .offset(x: 52, y: -38)

            Circle()
                .fill(isPlaying ? Color(hex: "EFF0A3") : Color.white)
                .frame(width: 12, height: 12)
                .offset(x: needleIsDown ? -44 : -52, y: needleIsDown ? 62 : 44)
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.82), value: needleIsDown)
        .contentShape(Rectangle())
        .onTapGesture {
            onNeedleChanged(!needleIsDown)
        }
    }
}

// MARK: - Progress

private struct RecapProgressBar: View {

    let currentIndex: Int
    let total: Int
    let activeColor: Color

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<max(total, 1), id: \.self) { index in
                Capsule()
                    .fill(index <= currentIndex ? activeColor : Color.black.opacity(0.12))
                    .frame(height: 3)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

// MARK: - Background

private var recapSoftBackground: some View {
    LinearGradient(
        colors: [
            Color(hex: "F7F7F2"),
            Color(hex: "D8DFE9").opacity(0.62),
            Color(hex: "EFF0A3").opacity(0.32)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}
