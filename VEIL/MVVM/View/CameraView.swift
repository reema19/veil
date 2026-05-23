//
//  CameraView.swift
//  VEIL
//
//  Created by Ghady Al Omar on 07/12/1447 AH.
//
import SwiftUI
import AVFoundation

struct CameraView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = CameraViewModel()

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color(red: 0.94, green: 0.94, blue: 0.91).ignoresSafeArea()

            VStack(spacing: 0) {
                // Close button
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(width: 36, height: 36)
                            .background(.white.opacity(0.55))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                Spacer()

                switch viewModel.cameraPermission {
                case .authorized:
                    ViewfinderView(viewModel: viewModel)
                        .padding(.horizontal, 20)
                case .denied, .restricted:
                    PermissionDeniedView()
                        .padding(.horizontal, 20)
                default:
                    RoundedRectangle(cornerRadius: 36)
                        .fill(Color(white: 0.847))
                        .aspectRatio(1, contentMode: .fit)
                        .padding(.horizontal, 20)
                }

                Text("Capture what held your attention.")
                    .font(.system(size: 16))
                    .foregroundColor(Color(white: 0.48))
                    .padding(.top, 22)
                    .padding(.bottom, 8)

                ShutterButton {
                    viewModel.capturePhoto()
                }
                .disabled(viewModel.cameraPermission != .authorized)
                .opacity(viewModel.cameraPermission == .authorized ? 1 : 0.4)
                .padding(.vertical, 60)
                .padding(.bottom, 12)
            }

            if let photo = viewModel.capturedImage {
                CapturedPhotoView(image: photo) {
                    viewModel.dismissCapturedPhoto()
                }
            }
        }
        .onAppear { viewModel.requestCameraPermission() }
        .onDisappear { viewModel.stopSession() }
    }
}

#Preview {
    CameraView()
}
