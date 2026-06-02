//
//  AudioRecorderService.swift
//  VEIL
//
//  Created by reema aljohani on 5/26/26.
//
import AVFoundation

final class AudioRecorderService {

    private var recorder: AVAudioRecorder?
    var audioURL: URL?

    func startRecording() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("veil-audio-\(UUID().uuidString).m4a")

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
        try session.setActive(true)

        recorder = try AVAudioRecorder(url: url, settings: settings)
        recorder?.isMeteringEnabled = true
        recorder?.record()

        audioURL = url
    }

    func stopRecording() {
        recorder?.stop()
        recorder = nil
        try? AVAudioSession.sharedInstance().setActive(false)
    }

    func updateMeters() -> Float {
        recorder?.updateMeters()
        return recorder?.averagePower(forChannel: 0) ?? -60
    }
}
