//
//  AudioRecorderService.swift
//  VEIL
//
//  Created by reema aljohani on 5/26/26.
//

import AVFoundation

final class AudioRecorderService: NSObject, AVAudioPlayerDelegate {

    private var recorder: AVAudioRecorder?
    private var player: AVAudioPlayer?

    var audioURL: URL?

    var isRecording: Bool {
        recorder?.isRecording ?? false
    }

    var isPlaying: Bool {
        player?.isPlaying ?? false
    }

    var playbackCurrentTime: TimeInterval {
        player?.currentTime ?? 0
    }

    var playbackDuration: TimeInterval {
        player?.duration ?? 1
    }

    func startRecording() throws {
        stopPlayback()

        let tempDirectory = FileManager.default.temporaryDirectory

        try FileManager.default.createDirectory(
            at: tempDirectory,
            withIntermediateDirectories: true
        )

        let url = tempDirectory
            .appendingPathComponent("veil-audio-\(UUID().uuidString)")
            .appendingPathExtension("m4a")

        audioURL = nil

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        let session = AVAudioSession.sharedInstance()

        try session.setCategory(
            .playAndRecord,
            mode: .default,
            options: [.defaultToSpeaker, .allowBluetooth]
        )

        try session.setActive(true)

        let newRecorder = try AVAudioRecorder(url: url, settings: settings)
        newRecorder.isMeteringEnabled = true
        newRecorder.prepareToRecord()

        guard newRecorder.record() else {
            throw NSError(
                domain: "AudioRecorderService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "AVAudioRecorder failed to start recording."]
            )
        }

        recorder = newRecorder
        audioURL = url

        print("Recording started at:", url.path)
    }

    func stopRecording() {
        guard let recorder else { return }

        let url = recorder.url

        recorder.stop()
        self.recorder = nil
        self.audioURL = url

        let exists = FileManager.default.fileExists(atPath: url.path)
        let size = ((try? FileManager.default.attributesOfItem(atPath: url.path)[.size]) as? NSNumber)?.intValue ?? 0

        print("Recording stopped.")
        print("Audio exists:", exists)
        print("Audio size:", size)
        print("Audio URL:", url.path)
    }

    func updateMeters() -> Float {
        guard let recorder, recorder.isRecording else {
            return -60
        }

        recorder.updateMeters()
        return recorder.averagePower(forChannel: 0)
    }

    func play(url: URL) throws {
        stopPlayback()

        guard FileManager.default.fileExists(atPath: url.path) else {
            throw NSError(
                domain: "AudioRecorderService",
                code: -2,
                userInfo: [NSLocalizedDescriptionKey: "Audio file does not exist."]
            )
        }

        let session = AVAudioSession.sharedInstance()

        try session.setCategory(
            .playAndRecord,
            mode: .default,
            options: [.defaultToSpeaker, .allowBluetooth]
        )

        try session.setActive(true)

        let newPlayer = try AVAudioPlayer(contentsOf: url)
        newPlayer.delegate = self
        newPlayer.volume = 1.0
        newPlayer.prepareToPlay()

        guard newPlayer.play() else {
            throw NSError(
                domain: "AudioRecorderService",
                code: -3,
                userInfo: [NSLocalizedDescriptionKey: "AVAudioPlayer failed to start playback."]
            )
        }

        player = newPlayer
    }

    func stopPlayback() {
        player?.stop()
        player = nil
    }

    func deactivateSession() {
        try? AVAudioSession.sharedInstance().setActive(
            false,
            options: .notifyOthersOnDeactivation
        )
    }
}
