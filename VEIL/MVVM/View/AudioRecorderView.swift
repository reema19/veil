//
//  AudioRecorderView.swift
//  VEIL
//
//  Created by reema aljohani on 5/26/26.
//

import SwiftUI
import SwiftData

struct AudioRecorderView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @StateObject private var viewModel = AudioRecorderViewModel()
    @State private var showSavedSheet = false

    let draft: ObservationDraft?

    init(draft: ObservationDraft? = nil) {
        self.draft = draft
    }

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

                if viewModel.state == .recorded {
                    recordedReviewView(screenWidth: width)
                        .position(x: width / 2, y: height * 0.50)
                } else {
                    recordingStartView(blobSize: blobSize)
                        .position(x: width / 2, y: height * 0.50)
                }

                if showSavedSheet {
                    MomentSavedSheetView(
                        onClose: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                showSavedSheet = false
                            }
                        },
                        onDone: {
                            NotificationCenter.default.post(
                                name: .observationSavedGoHome,
                                object: nil
                            )
                            dismiss()
                        }
                    )
                    .zIndex(5)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .onDisappear {
            viewModel.cleanUp()
        }
    }

    // MARK: - Start View

    private func recordingStartView(blobSize: CGFloat) -> some View {

        VStack(spacing: 12) {

            ZStack {

                if viewModel.state == .recording {
                    AudioBlob(
                        size: blobSize * 1.55,
                        opacity: 0.10,
                        level: viewModel.soundLevel
                    )

                    AudioBlob(
                        size: blobSize * 1.28,
                        opacity: 0.18,
                        level: viewModel.soundLevel * 0.9
                    )

                    AudioBlob(
                        size: blobSize,
                        opacity: 1.0,
                        level: viewModel.soundLevel
                    )
                } else {
                    OrganicAudioBlob()
                        .fill(Color.white)
                        .frame(width: blobSize, height: blobSize)
                }

                Image(systemName: "mic")
                    .font(.system(size: 48))
                    .foregroundColor(.black)
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if viewModel.state == .idle {
                            viewModel.startRecording(sourceDraft: draft)
                        }
                    }
                    .onEnded { _ in
                        if viewModel.state == .recording {
                            viewModel.stopRecording(sourceDraft: draft)
                        }
                    }
            )

            if viewModel.state == .recording {
                Text(viewModel.remainingSecondsText)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.black)
            }

            Text(helperText)
                .font(.system(size: 16))
                .foregroundColor(.black.opacity(0.65))
        }
    }

    // MARK: - Recorded View

    private func recordedReviewView(screenWidth: CGFloat) -> some View {

        let buttonSize: CGFloat = 54
        let waveformWidth = min(screenWidth * 0.58, 230)

        return VStack(spacing: 18) {

            HStack(spacing: 16) {

                Button {
                    viewModel.resetRecording()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(.black)
                        .frame(width: buttonSize, height: buttonSize)
                        .background(Color.white)
                        .clipShape(Circle())
                }

                waveformView
                    .frame(width: waveformWidth, height: 56)

                Button {
                    saveAudio()
                } label: {
                    Image(systemName: "checkmark")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(.black)
                        .frame(width: buttonSize, height: buttonSize)
                        .background(Color.white)
                        .clipShape(Circle())
                }
            }

            Text(viewModel.formattedTime)
                .font(.system(size: 16))
                .foregroundColor(.black.opacity(0.7))
        }
    }

    // MARK: - Save Audio

    private func saveAudio() {

        guard let draft = draft else {
            print("Missing observation draft")
            return
        }

        guard let recording = viewModel.recordingDraft else {
            print("Missing recorded audio draft")
            return
        }

        do {
            let fileName = try MediaStorageService.shared.moveAudioToDocuments(
                temporaryURL: recording.audioURL
            )

            guard let place = try fetchPlace(with: draft.placeID) else {
                print("Could not find place for audio observation")
                return
            }

            let observation = PlaceObservation(
                sense: draft.sense,
                promptText: draft.prompt,
                mediaFileName: fileName,
                durationSeconds: recording.durationSeconds,
                place: place
            )

            modelContext.insert(observation)
            try modelContext.save()

            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                showSavedSheet = true
            }

        } catch {
            print("Save audio failed:", error)
        }
    }

    // MARK: - Safe Place Fetch

    private func fetchPlace(with id: UUID) throws -> Place? {
        let descriptor = FetchDescriptor<Place>()
        let places = try modelContext.fetch(descriptor)

        return places.first { place in
            place.id == id
        }
    }

    // MARK: - Waveform

    private var waveformView: some View {
        GeometryReader { _ in
            HStack(spacing: 4) {
                ForEach(viewModel.waveformSamples, id: \.self) { value in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.black.opacity(0.3))
                        .frame(width: 3, height: max(6, value * 50))
                }
            }
        }
    }

    // MARK: - Helper

    private var helperText: String {
        switch viewModel.state {
        case .idle:
            return "Hold to record"
        case .recording:
            return "Recording..."
        case .recorded:
            return "Review before saving"
        }
    }
}

// MARK: - Organic Audio Blob

struct OrganicAudioBlob: Shape {

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let w = rect.width
        let h = rect.height

        path.move(to: CGPoint(x: 0.58 * w, y: 0.02 * h))

        path.addCurve(
            to: CGPoint(x: 0.96 * w, y: 0.28 * h),
            control1: CGPoint(x: 0.75 * w, y: 0.03 * h),
            control2: CGPoint(x: 0.94 * w, y: 0.12 * h)
        )

        path.addCurve(
            to: CGPoint(x: 0.82 * w, y: 0.86 * h),
            control1: CGPoint(x: 1.00 * w, y: 0.48 * h),
            control2: CGPoint(x: 0.98 * w, y: 0.74 * h)
        )

        path.addCurve(
            to: CGPoint(x: 0.33 * w, y: 0.96 * h),
            control1: CGPoint(x: 0.66 * w, y: 0.99 * h),
            control2: CGPoint(x: 0.49 * w, y: 1.00 * h)
        )

        path.addCurve(
            to: CGPoint(x: 0.02 * w, y: 0.58 * h),
            control1: CGPoint(x: 0.16 * w, y: 0.92 * h),
            control2: CGPoint(x: 0.03 * w, y: 0.78 * h)
        )

        path.addCurve(
            to: CGPoint(x: 0.22 * w, y: 0.12 * h),
            control1: CGPoint(x: 0.00 * w, y: 0.39 * h),
            control2: CGPoint(x: 0.05 * w, y: 0.22 * h)
        )

        path.addCurve(
            to: CGPoint(x: 0.58 * w, y: 0.02 * h),
            control1: CGPoint(x: 0.34 * w, y: 0.04 * h),
            control2: CGPoint(x: 0.46 * w, y: 0.00 * h)
        )

        return path
    }
}

// MARK: - Audio Blob View

struct AudioBlob: View {

    let size: CGFloat
    let opacity: Double
    let level: CGFloat

    var body: some View {
        OrganicAudioBlob()
            .fill(Color.white.opacity(opacity))
            .frame(width: size, height: size)
            .scaleEffect(1 + level * 0.22)
            .animation(.easeInOut(duration: 0.16), value: level)
    }
}
