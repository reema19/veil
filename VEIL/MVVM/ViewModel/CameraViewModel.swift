//
//  CameraViewModel.swift
//  VEIL
//
//  Created by Ghady Al Omar on 07/12/1447 AH.
//

import AVFoundation
import SwiftUI
import Combine

// الوسيط بين الـ View والـ Service — يحمل الـ state ويعرض actions
class CameraViewModel: ObservableObject {
    @Published var capturedImage: UIImage?
    @Published var selectedZoom: ZoomLevel = .one
    @Published var cameraPermission: AVAuthorizationStatus = .notDetermined

    private let cameraService = CameraService()

    var session: AVCaptureSession { cameraService.session }

    init() {
        cameraService.onPhotoCaptured = { [weak self] image in
            self?.capturedImage = image
        }
    }

    // MARK: - Permissions
    func requestCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.cameraPermission = granted ? .authorized : .denied
                    if granted { self?.cameraService.startSession() }
                }
            }
        case .authorized:
            cameraPermission = .authorized
            cameraService.startSession()
        default:
            cameraPermission = status
        }
    }

    // MARK: - Actions
    func stopSession() {
        cameraService.stopSession()
    }

    func setZoom(_ level: ZoomLevel) {
        selectedZoom = level
        cameraService.setZoom(level)
    }

    func capturePhoto() {
        cameraService.capturePhoto()
    }

    func dismissCapturedPhoto() {
        capturedImage = nil
    }
}
