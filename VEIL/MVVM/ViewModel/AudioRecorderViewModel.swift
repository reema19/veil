//
//  AudioRecorderViewModel.swift
//  VEIL
//
//  Created by reema aljohani on 5/26/26.
//

import Foundation
import AVFoundation
import Combine
import SwiftUI

enum AudioRecordingState {
    case idle
    case recording
    case recorded
}

struct AudioRecordingDraft {
    let audioURL: URL
    let durationSeconds: Int
    let waveformSamples: [CGFloat]

    let placeTitle: String?
    let placeCurrentDay: Int?
    let placeTotalDays: Int?
    let prompt: String?
}

final class AudioRecorderViewModel: ObservableObject {

    private let maxRecordingSeconds = 5

    @Published var state: AudioRecordingState = .idle
    @Published var seconds: Int = 0
    @Published var soundLevel: CGFloat = 0.05
    @Published var audioURL: URL?
    @Published var waveformSamples: [CGFloat] = []
    @Published var playbackProgress: CGFloat = 0
    @Published var recordingDraft: AudioRecordingDraft?

    private let service = AudioRecorderService()
    private var timer: Timer?
    private var startDate = Date()

    var formattedTime: String {
        String(format: "00:%02d", seconds)
    }

    var remainingSecondsText: String {
        "\(max(0, maxRecordingSeconds - seconds))s left"
    }

    var recordingProgress: CGFloat {
        min(CGFloat(seconds) / CGFloat(maxRecordingSeconds), 1)
    }

    func startRecording() {
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
            DispatchQueue.main.async {
                guard let self else { return }

                guard granted else {
                    print("Microphone permission denied")
                    return
                }

                do {
                    try self.service.startRecording()
                    self.state = .recording
                    self.seconds = 0
                    self.soundLevel = 0.05
                    self.waveformSamples = []
                    self.playbackProgress = 0
                    self.recordingDraft = nil
                    self.startDate = Date()
                    self.startTimer()
                } catch {
                    print("Failed to start audio recording:", error)
                }
            }
        }
    }

    func stopRecording(sourceDraft: ObservationDraft?) {
        guard state == .recording else { return }

        service.stopRecording()
        audioURL = service.audioURL
        state = .recorded

        timer?.invalidate()
        timer = nil

        fillWaveformSamplesIfNeeded()

        if let audioURL {
            recordingDraft = AudioRecordingDraft(
                audioURL: audioURL,
                durationSeconds: seconds,
                waveformSamples: waveformSamples,
                placeTitle: sourceDraft?.placeTitle,
                placeCurrentDay: sourceDraft?.placeCurrentDay,
                placeTotalDays: sourceDraft?.placeTotalDays,
                prompt: sourceDraft?.prompt
            )
        }

        startPlaybackAnimation()
    }

    func resetRecording() {
        service.stopRecording()
        audioURL = nil
        seconds = 0
        soundLevel = 0.05
        waveformSamples = []
        playbackProgress = 0
        recordingDraft = nil
        state = .idle
        timer?.invalidate()
        timer = nil
    }

    func cleanUp() {
        service.stopRecording()
        timer?.invalidate()
        timer = nil
    }

    private func startTimer() {
        timer?.invalidate()

        timer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { [weak self] _ in
            guard let self else { return }

            let power = service.updateMeters()
            let level = normalizedPower(power)

            soundLevel = level
            appendWaveformSample(level)

            if state == .recording {
                seconds = Int(Date().timeIntervalSince(startDate))

                if seconds >= maxRecordingSeconds {
                    stopRecording(sourceDraft: nil)
                }
            }
        }
    }

    private func appendWaveformSample(_ level: CGFloat) {
        waveformSamples.append(level)

        if waveformSamples.count > 18 {
            waveformSamples.removeFirst()
        }
    }

    private func fillWaveformSamplesIfNeeded() {
        while waveformSamples.count < 18 {
            waveformSamples.append(0.12)
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

    private func normalizedPower(_ power: Float) -> CGFloat {
        let minDb: Float = -55
        let clamped = max(power, minDb)
        let normalized = (clamped - minDb) / abs(minDb)
        return CGFloat(normalized)
    }
}
