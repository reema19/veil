//
//  CameraService.swift
//  VEIL
//
//  Created by Ghady Al Omar on 07/12/1447 AH.
//
import AVFoundation
import UIKit

// مسؤول فقط عن التعامل مع AVFoundation
class CameraService: NSObject {
    let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()
    var onPhotoCaptured: ((UIImage) -> Void)?

    func startSession() {
        guard !session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.beginConfiguration()
            self.session.sessionPreset = .photo

            guard
                let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                let input = try? AVCaptureDeviceInput(device: device),
                self.session.canAddInput(input)
            else { self.session.commitConfiguration(); return }

            self.session.addInput(input)
            if self.session.canAddOutput(self.output) {
                self.session.addOutput(self.output)
            }
            self.session.commitConfiguration()
            self.session.startRunning()
        }
    }

    func stopSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            if self.session.isRunning { self.session.stopRunning() }
        }
    }

    func setZoom(_ level: ZoomLevel) {
        guard let device = (session.inputs.first as? AVCaptureDeviceInput)?.device else { return }
        try? device.lockForConfiguration()
        device.videoZoomFactor = max(device.minAvailableVideoZoomFactor,
                                     min(level.factor, device.maxAvailableVideoZoomFactor))
        device.unlockForConfiguration()
    }

    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: self)
    }
}

extension CameraService: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        guard error == nil,
              let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else { return }
        DispatchQueue.main.async {
            self.onPhotoCaptured?(image)
        }
    }
}
