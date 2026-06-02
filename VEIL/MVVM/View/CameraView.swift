//
//  CameraView.swift
//  VEIL
//
//  Created by Ghady Al Omar on 07/12/1447 AH.
//
import SwiftUI
import AVFoundation

struct CameraView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = CameraViewModel()

    let draft: ObservationDraft?

    init(draft: ObservationDraft? = nil) {
        self.draft = draft
    }

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height

            let cameraSize = min(width - 56, height * 0.43)

            ZStack {
                Color(hex: "F4F4E8")
                    .ignoresSafeArea()

                VStack(spacing: 0) {

                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 22, weight: .medium))
                                .foregroundColor(.black)
                                .frame(width: 50, height: 50)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                                .shadow(
                                    color: .black.opacity(0.08),
                                    radius: 12,
                                    x: 0,
                                    y: 6
                                )
                        }
                        .buttonStyle(.plain)

                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)

                    Spacer(minLength: 46)

                    cameraContent
                        .frame(width: cameraSize, height: cameraSize)
                        .clipShape(RoundedRectangle(cornerRadius: 42, style: .continuous))

                    Text("Capture what held your attention.")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(Color("SubtitleColor"))
                        .multilineTextAlignment(.center)
                        .padding(.top, 28)

                    Spacer(minLength: 26)

                    ShutterButton {
                        viewModel.capturePhoto()
                    }
                    .disabled(viewModel.cameraPermission != .authorized)
                    .opacity(viewModel.cameraPermission == .authorized ? 1 : 0.45)

                    Spacer(minLength: 48)
                }

                if let photo = viewModel.capturedImage {
                    CapturedPhotoView(
                        image: photo,
                        onDismiss: {
                            viewModel.dismissCapturedPhoto()
                        },
                        onSave: {
                            print("Save photo later")
                        }
                    )
                    .zIndex(2)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            viewModel.requestCameraPermission()
        }
        .onDisappear {
            viewModel.stopSession()
        }
    }

    @ViewBuilder
    private var cameraContent: some View {
        switch viewModel.cameraPermission {
        case .authorized:
            ViewfinderView(viewModel: viewModel)

        case .denied, .restricted:
            PermissionDeniedView()

        default:
            RoundedRectangle(cornerRadius: 42, style: .continuous)
                .fill(Color(red: 0.84, green: 0.84, blue: 0.80))
                .overlay(
                    RoundedRectangle(cornerRadius: 42, style: .continuous)
                        .stroke(Color.white.opacity(0.38), lineWidth: 1.2)
                        .padding(68)
                )
        }
    }
}

#Preview {
    CameraView()
}
