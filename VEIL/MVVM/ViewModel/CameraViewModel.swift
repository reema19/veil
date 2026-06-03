//
//  CameraViewModel.swift
//  VEIL
//
//  Created by Ghady Al Omar on 07/12/1447 AH.
//

import AVFoundation
import SwiftUI
import Combine

final class CameraViewModel: ObservableObject {

    @Published var capturedImage: UIImage?
    @Published var selectedZoom: ZoomLevel = .one
    @Published var cameraPermission: AVAuthorizationStatus = .notDetermined
    @Published var isFlashOn: Bool = false

    private let cameraService = CameraService()
    private var isSessionStarted = false

    var session: AVCaptureSession {
        cameraService.session
    }

    init() {
        cameraService.onPhotoCaptured = { [weak self] image in
            DispatchQueue.main.async {
                self?.capturedImage = image
            }
        }
    }

    func requestCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)

        switch status {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.cameraPermission = granted ? .authorized : .denied

                    if granted {
                        self?.startSessionIfNeeded()
                    }
                }
            }

        case .authorized:
            cameraPermission = .authorized
            startSessionIfNeeded()

        case .denied, .restricted:
            cameraPermission = status

        @unknown default:
            cameraPermission = status
        }
    }

    func stopSession() {
        guard isSessionStarted else { return }

        cameraService.stopSession()
        isSessionStarted = false
    }

    func setZoom(_ level: ZoomLevel) {
        selectedZoom = level
        cameraService.setZoom(level)
    }

    func toggleFlash() {
        isFlashOn.toggle()
        cameraService.setFlashEnabled(isFlashOn)
    }

    func capturePhoto() {
        cameraService.capturePhoto()
    }

    func dismissCapturedPhoto() {
        capturedImage = nil
    }

    private func startSessionIfNeeded() {
        guard !isSessionStarted else { return }

        cameraService.startSession()
        isSessionStarted = true
    }
}
