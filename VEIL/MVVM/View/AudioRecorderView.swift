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

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 21, weight: .medium))
                        .foregroundColor(.black)
                        .frame(width: 50, height: 50)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
                }
                .buttonStyle(.plain)
                .position(x: 49, y: 45)

                if viewModel.state == .recorded {
                    recordedReviewView(screenWidth: width)
                        .position(x: width / 2, y: height * 0.47)
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

                            showSavedSheet = false
                            dismiss()
                        }
                    )
                    .zIndex(5)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onDisappear {
            viewModel.cleanUp()
        }
    }

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

                if viewModel.state == .recording {
                    OrganicAudioBlob()
                        .stroke(Color.white.opacity(0.40), lineWidth: 1)
                        .frame(width: blobSize, height: blobSize)

                    OrganicAudioBlob()
                        .trim(from: 0, to: viewModel.recordingProgress)
                        .stroke(
                            Color(hex: "EFF0A3"),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .frame(width: blobSize, height: blobSize)
                        .animation(.linear(duration: 0.1), value: viewModel.recordingProgress)
                }

                Image(systemName: "mic")
                    .font(.system(size: 48, weight: .regular))
                    .foregroundColor(.black)
            }
            .contentShape(Rectangle())
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
        let waveformWidth = min(screenWidth * 0.58, 230)

        return VStack(spacing: 18) {
            HStack(spacing: 14) {
                Button {
                    viewModel.resetRecording()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 21, weight: .medium))
                        .foregroundColor(.black)
                        .frame(width: buttonSize, height: buttonSize)
                        .background(Color.white)
                        .clipShape(Circle())
                }

                waveformView
                    .frame(width: waveformWidth, height: 56)
                    .clipped()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.playRecording()
                    }

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
            .buttonStyle(.plain)

            Text(viewModel.formattedTime)
                .font(.custom("DMSans-Regular", size: 14))
                .foregroundColor(Color("TitleColor"))

            Text("Listen back before saving")
                .font(.custom("DMSans-Regular", size: 14))
                .foregroundColor(Color("SubtitleColor"))
        }
    }

    private var waveformView: some View {
        GeometryReader { proxy in
            let samples = normalizedWaveformSamples
            let movement = max(0, proxy.size.width - 20)
            let playheadX = viewModel.playbackProgress * movement

            ZStack(alignment: .leading) {
                HStack(spacing: 4.5) {
                    ForEach(samples.indices, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.black.opacity(0.25))
                            .frame(
                                width: 3.5,
                                height: max(8, samples[index] * 50)
                            )
                            .frame(height: 56, alignment: .center)
                    }

                    Rectangle()
                        .fill(Color.black.opacity(0.22))
                        .frame(width: 64, height: 2)
                        .padding(.leading, 3)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(hex: "EFF0A3"))
                    .frame(width: 3.5, height: 52)
                    .offset(x: playheadX)

                Circle()
                    .fill(Color(hex: "EFF0A3"))
                    .frame(width: 7, height: 7)
                    .offset(x: playheadX - 1.75, y: -26)
            }
        }
    }

    private var normalizedWaveformSamples: [CGFloat] {
        let samples = viewModel.waveformSamples

        if samples.isEmpty {
            return Array(repeating: 0.12, count: 26)
        }

        return samples.map { sample in
            min(max(sample, 0.12), 1.0)
        }
    }

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

    private func fetchPlace(with id: UUID) throws -> Place? {
        let descriptor = FetchDescriptor<Place>()
        let places = try modelContext.fetch(descriptor)

        return places.first { place in
            place.id == id
        }
    }

    private var helperText: String {
        switch viewModel.state {
        case .idle:
            return "Hold to record"
        case .recording:
            return "Release to finish, or let it end automatically"
        case .recorded:
            return "Listen back before saving"
        }
    }
}

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

struct AudioBlob: View {

    let size: CGFloat
    let opacity: Double
    let level: CGFloat

    var body: some View {
        OrganicAudioBlob()
            .fill(Color.white.opacity(opacity))
            .frame(width: size, height: size)
            .scaleEffect(1 + level * 0.22)
            .animation(.easeInOut(duration: 0.14), value: level)
    }
}
