//  AudioRecorderSandboxView.swift
//  VEIL

import SwiftUI

struct AudioRecorderSandboxView: View {

    enum DemoState {
        case idle, recording, recorded
    }

    private let maxRecordingSeconds = 5

    @State private var state: DemoState = .idle
    @State private var seconds = 0
    @State private var soundLevel: CGFloat = 0.2
    @State private var timer: Timer?
    @State private var playbackProgress: CGFloat = 0
    @State private var waveformSamples: [CGFloat] = []

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let blobSize = min(width * 0.42, 160)

            ZStack {
                LinearGradient(
                    colors: [
                        Color(hex: "D8DFE9").opacity(0.0),
                        Color(hex: "D8DFE9").opacity(0.68),
                        Color(hex: "D8DFE9").opacity(0.90)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                Button { reset() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(.black)
                        .frame(width: 50, height: 50)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
                }
                .buttonStyle(.plain)
                .position(x: 49, y: 45)

                if state == .recorded {
                    recordedReviewView(screenWidth: width)
                        .position(x: width / 2, y: height * 0.47)
                } else {
                    recordingStartView(blobSize: blobSize)
                        .position(x: width / 2, y: height * 0.50)
                }
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    private func recordingStartView(blobSize: CGFloat) -> some View {
        VStack(spacing: 12) {
            ZStack {
                if state == .recording {
                    SandboxAudioBlob(size: blobSize * 1.55, opacity: 0.10, level: soundLevel)
                    SandboxAudioBlob(size: blobSize * 1.28, opacity: 0.18, level: soundLevel * 0.9)
                    SandboxAudioBlob(size: blobSize, opacity: 1.0, level: soundLevel)
                } else {
                    SandboxOrganicBlob()
                        .fill(Color.white)
                        .frame(width: blobSize, height: blobSize)
                }

                if state == .recording {
                    SandboxOrganicBlob()
                        .stroke(Color.white.opacity(0.38), lineWidth: 1)
                        .frame(width: blobSize, height: blobSize)

                    SandboxOrganicBlob()
                        .trim(from: 0, to: recordingProgress)
                        .stroke(
                            Color(hex: "EFF0A3"),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .frame(width: blobSize, height: blobSize)
                        .animation(.linear(duration: 0.2), value: recordingProgress)
                }

                Image(systemName: "mic")
                    .font(.system(size: 48, weight: .regular))
                    .foregroundColor(.black)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if state == .idle {
                            startDemoRecording()
                        }
                    }
                    .onEnded { _ in
                        if state == .recording {
                            stopDemoRecording()
                        }
                    }
            )

            if state == .recording {
                Text("\(max(0, maxRecordingSeconds - seconds))s left")
                    .font(.custom("DMSans-Regular", size: 15))
                    .foregroundColor(Color("TitleColor"))
            }

            Text(helperText)
                .font(.custom("DMSans-Regular", size: 14))
                .foregroundColor(Color("SubtitleColor"))
                .multilineTextAlignment(.center)
        }
    }

    private func recordedReviewView(screenWidth: CGFloat) -> some View {
        let buttonSize: CGFloat = 54
        let sideSpacing: CGFloat = 14
        let waveformWidth = min(screenWidth * 0.58, 230)

        return VStack(spacing: 18) {
            HStack(spacing: sideSpacing) {
                Button { reset() } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.black)
                        .frame(width: buttonSize, height: buttonSize)
                        .background(Color.white)
                        .clipShape(Circle())
                }

                sandboxWaveform
                    .frame(width: waveformWidth, height: 56)
                    .clipped()

                Button { reset() } label: {
                    Image(systemName: "checkmark")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.black)
                        .frame(width: buttonSize, height: buttonSize)
                        .background(Color.white)
                        .clipShape(Circle())
                }
            }
            .buttonStyle(.plain)

            Text(formatTime(seconds))
                .font(.custom("DMSans-Regular", size: 14))
                .foregroundColor(Color("TitleColor"))

            Text("Listen back before saving")
                .font(.custom("DMSans-Regular", size: 14))
                .foregroundColor(Color("SubtitleColor"))
        }
    }

    private var sandboxWaveform: some View {
        GeometryReader { proxy in
            let movement = max(0, proxy.size.width - 18)
            let playheadX = playbackProgress * movement
            let samples = normalizedWaveformSamples

            ZStack(alignment: .leading) {
                HStack(spacing: 5.5) {
                    ForEach(samples.indices, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.black.opacity(0.25))
                            .frame(width: 3.5, height: max(6, samples[index] * 52))
                    }

                    Rectangle()
                        .fill(Color.black.opacity(0.25))
                        .frame(width: 64, height: 2)
                        .padding(.leading, 4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(hex: "EFF0A3"))
                    .frame(width: 3.5, height: 52)
                    .offset(x: playheadX)

                Circle()
                    .fill(Color(hex: "EFF0A3"))
                    .frame(width: 8, height: 6)
                    .offset(x: playheadX - 2, y: -26)
            }
        }
    }

    private var normalizedWaveformSamples: [CGFloat] {
        if waveformSamples.isEmpty {
            return Array(repeating: 0.3, count: 18)
        }

        return waveformSamples.prefix(18).map { sample in
            min(max(sample, 0.12), 1.0)
        }
    }

    private var helperText: String {
        switch state {
        case .idle:
            return "Hold to record · up to 5 seconds"
        case .recording:
            return "Release to finish, or let it end automatically"
        case .recorded:
            return "Listen back before saving"
        }
    }

    private var recordingProgress: CGFloat {
        min(CGFloat(seconds) / CGFloat(maxRecordingSeconds), 1)
    }

    private func startDemoRecording() {
        state = .recording
        seconds = 0
        playbackProgress = 0
        waveformSamples = []

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            soundLevel = CGFloat.random(in: 0.12...0.9)
            waveformSamples.append(soundLevel)

            if seconds < maxRecordingSeconds {
                seconds += 1
            }

            if seconds >= maxRecordingSeconds {
                stopDemoRecording()
            }
        }
    }

    private func stopDemoRecording() {
        guard state == .recording else { return }

        state = .recorded
        timer?.invalidate()
        timer = nil
        soundLevel = 0.2
        fillWaveformSamplesIfNeeded()
        startPlaybackAnimation()
    }

    private func fillWaveformSamplesIfNeeded() {
        while waveformSamples.count < 18 {
            waveformSamples.append(CGFloat.random(in: 0.12...0.9))
        }
    }

    private func startPlaybackAnimation() {
        playbackProgress = 0

        withAnimation(
            .linear(duration: Double(max(seconds, 1)))
            .repeatForever(autoreverses: false)
        ) {
            playbackProgress = 1
        }
    }

    private func reset() {
        state = .idle
        seconds = 0
        soundLevel = 0.2
        playbackProgress = 0
        waveformSamples = []
        timer?.invalidate()
        timer = nil
    }

    private func formatTime(_ seconds: Int) -> String {
        String(format: "00:%02d", seconds)
    }
}

struct SandboxAudioBlob: View {
    let size: CGFloat
    let opacity: Double
    let level: CGFloat

    var body: some View {
        SandboxOrganicBlob()
            .fill(Color.white.opacity(opacity))
            .frame(width: size, height: size)
            .scaleEffect(1 + level * 0.22)
            .animation(.easeInOut(duration: 0.16), value: level)
    }
}

struct SandboxOrganicBlob: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        path.move(to: CGPoint(x: 0.58 * w, y: 0.02 * h))
        path.addCurve(to: CGPoint(x: 0.96 * w, y: 0.28 * h), control1: CGPoint(x: 0.75 * w, y: 0.03 * h), control2: CGPoint(x: 0.94 * w, y: 0.12 * h))
        path.addCurve(to: CGPoint(x: 0.82 * w, y: 0.86 * h), control1: CGPoint(x: 1.00 * w, y: 0.48 * h), control2: CGPoint(x: 0.98 * w, y: 0.74 * h))
        path.addCurve(to: CGPoint(x: 0.33 * w, y: 0.96 * h), control1: CGPoint(x: 0.66 * w, y: 0.99 * h), control2: CGPoint(x: 0.49 * w, y: 1.00 * h))
        path.addCurve(to: CGPoint(x: 0.02 * w, y: 0.58 * h), control1: CGPoint(x: 0.16 * w, y: 0.92 * h), control2: CGPoint(x: 0.03 * w, y: 0.78 * h))
        path.addCurve(to: CGPoint(x: 0.22 * w, y: 0.12 * h), control1: CGPoint(x: 0.00 * w, y: 0.39 * h), control2: CGPoint(x: 0.05 * w, y: 0.22 * h))
        path.addCurve(to: CGPoint(x: 0.58 * w, y: 0.02 * h), control1: CGPoint(x: 0.34 * w, y: 0.04 * h), control2: CGPoint(x: 0.46 * w, y: 0.00 * h))

        return path
    }
}

#Preview {
    AudioRecorderSandboxView()
}
