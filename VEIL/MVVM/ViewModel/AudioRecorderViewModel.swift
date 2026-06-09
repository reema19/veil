//
//  AudioRecorderViewModel.swift
//  VEIL
//
//  Created by reema aljohani on 5/26/26.
//


import Foundation
import AVFoundation
import SwiftUI
import Combine

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
    private let visibleWaveformBars = 26

    @Published var state: AudioRecordingState = .idle
    @Published var seconds: Int = 0
    @Published var soundLevel: CGFloat = 0.05
    @Published var audioURL: URL?
    @Published var waveformSamples: [CGFloat] = []
    @Published var playbackProgress: CGFloat = 0
    @Published var recordingDraft: AudioRecordingDraft?

    private let service = AudioRecorderService()

    private var meterTimer: Timer?
    private var playbackTimer: Timer?
    private var startDate = Date()
    private var latestSourceDraft: ObservationDraft?

    var formattedTime: String {
        String(format: "00:%02d", seconds)
    }

    var remainingSecondsText: String {
        "\(max(0, maxRecordingSeconds - seconds))s left"
    }

    var recordingProgress: CGFloat {
        guard state == .recording else { return 0 }
        return min(CGFloat(Date().timeIntervalSince(startDate)) / CGFloat(maxRecordingSeconds), 1)
    }

    func startRecording(sourceDraft: ObservationDraft? = nil) {
        guard state == .idle else { return }

        latestSourceDraft = sourceDraft

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
                    self.audioURL = nil
                    self.waveformSamples = Array(repeating: 0.08, count: self.visibleWaveformBars)
                    self.playbackProgress = 0
                    self.recordingDraft = nil
                    self.startDate = Date()

                    self.startMeterTimer()

                } catch {
                    print("Failed to start audio recording:", error.localizedDescription)
                }
            }
        }
    }

    func stopRecording(sourceDraft: ObservationDraft? = nil) {
        guard state == .recording else { return }

        let finalDraft = sourceDraft ?? latestSourceDraft
        let realDuration = min(
            maxRecordingSeconds,
            max(1, Int(ceil(Date().timeIntervalSince(startDate))))
        )

        meterTimer?.invalidate()
        meterTimer = nil

        service.stopRecording()

        guard let finalAudioURL = service.audioURL else {
            print("Missing audio URL after recording")
            resetRecording()
            return
        }

        audioURL = finalAudioURL
        seconds = realDuration
        soundLevel = 0.05
        state = .recorded

        waveformSamples = buildWaveformFromAudioFile(
            url: finalAudioURL,
            barCount: visibleWaveformBars
        )

        recordingDraft = AudioRecordingDraft(
            audioURL: finalAudioURL,
            durationSeconds: realDuration,
            waveformSamples: waveformSamples,
            placeTitle: finalDraft?.placeTitle,
            placeCurrentDay: finalDraft?.placeCurrentDay,
            placeTotalDays: finalDraft?.placeTotalDays,
            prompt: finalDraft?.prompt
        )

        print("Final waveform:", waveformSamples)
    }

    func playRecording() {
        guard let url = audioURL else {
            print("No audio URL to play")
            return
        }

        do {
            playbackProgress = 0
            try service.play(url: url)
            startPlaybackTimer()
        } catch {
            print("Playback failed:", error.localizedDescription)
        }
    }

    func resetRecording() {
        service.stopRecording()
        service.stopPlayback()

        meterTimer?.invalidate()
        playbackTimer?.invalidate()

        meterTimer = nil
        playbackTimer = nil

        state = .idle
        seconds = 0
        soundLevel = 0.05
        audioURL = nil
        waveformSamples = []
        playbackProgress = 0
        recordingDraft = nil
        latestSourceDraft = nil
    }

    func cleanUp() {
        if state == .recording {
            service.stopRecording()
        }

        service.stopPlayback()
        service.deactivateSession()

        meterTimer?.invalidate()
        playbackTimer?.invalidate()

        meterTimer = nil
        playbackTimer = nil
    }

    private func startMeterTimer() {
        meterTimer?.invalidate()

        let timer = Timer(timeInterval: 0.035, repeats: true) { [weak self] _ in
            guard let self else { return }
            guard self.state == .recording else { return }

            let elapsed = Date().timeIntervalSince(self.startDate)

            if elapsed >= Double(self.maxRecordingSeconds) {
                self.stopRecording()
                return
            }

            let power = self.service.updateMeters()
            let level = self.normalizedPower(power)

            self.soundLevel = level
            self.seconds = Int(elapsed)
        }

        meterTimer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    private func startPlaybackTimer() {
        playbackTimer?.invalidate()

        let timer = Timer(timeInterval: 0.02, repeats: true) { [weak self] timer in
            guard let self else { return }

            let duration = max(self.service.playbackDuration, 0.1)
            let current = self.service.playbackCurrentTime

            self.playbackProgress = min(CGFloat(current / duration), 1)

            if !self.service.isPlaying {
                self.playbackProgress = 1
                timer.invalidate()
            }
        }

        playbackTimer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    private func buildWaveformFromAudioFile(url: URL, barCount: Int) -> [CGFloat] {
        do {
            let file = try AVAudioFile(forReading: url)
            let format = file.processingFormat
            let frameCount = AVAudioFrameCount(file.length)

            guard let buffer = AVAudioPCMBuffer(
                pcmFormat: format,
                frameCapacity: frameCount
            ) else {
                return Array(repeating: 0.08, count: barCount)
            }

            try file.read(into: buffer)

            guard let channelData = buffer.floatChannelData?[0] else {
                return Array(repeating: 0.08, count: barCount)
            }

            let totalFrames = Int(buffer.frameLength)

            guard totalFrames > 0 else {
                return Array(repeating: 0.08, count: barCount)
            }

            let framesPerBar = max(totalFrames / barCount, 1)

            var bars: [CGFloat] = []

            for barIndex in 0..<barCount {
                let start = barIndex * framesPerBar
                let end = min(start + framesPerBar, totalFrames)

                if start >= end {
                    bars.append(0.08)
                    continue
                }

                var sum: Float = 0

                for frame in start..<end {
                    let sample = channelData[frame]
                    sum += sample * sample
                }

                let mean = sum / Float(end - start)
                let rms = sqrt(mean)

                bars.append(CGFloat(rms))
            }

            let maxValue = bars.max() ?? 0.001

            let normalized = bars.map { value -> CGFloat in
                let boosted = value / maxValue
                let shaped = pow(boosted, 0.55)
                return min(max(shaped, 0.08), 1.0)
            }

            return smoothWaveform(normalized)

        } catch {
            print("Failed to build waveform from audio file:", error.localizedDescription)
            return Array(repeating: 0.08, count: barCount)
        }
    }

    private func smoothWaveform(_ values: [CGFloat]) -> [CGFloat] {
        guard values.count > 2 else { return values }

        return values.indices.map { index in
            let previous = index > 0 ? values[index - 1] : values[index]
            let current = values[index]
            let next = index < values.count - 1 ? values[index + 1] : values[index]

            return (previous * 0.18) + (current * 0.64) + (next * 0.18)
        }
    }

    private func normalizedPower(_ power: Float) -> CGFloat {
        let minDb: Float = -60

        if power <= minDb {
            return 0.05
        }

        let clamped = min(max(power, minDb), 0)
        let normalized = (clamped - minDb) / abs(minDb)
        let curved = pow(normalized, 0.45)

        return CGFloat(min(max(curved, 0.05), 1.0))
    }
}
