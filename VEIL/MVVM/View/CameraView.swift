//
//  CameraView.swift
//  VEIL
//
//  Created by Ghady Al Omar on 07/12/1447 AH.
//


import SwiftUI
import AVFoundation
import SwiftData
import UIKit

struct CameraView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @StateObject private var viewModel = CameraViewModel()
    @State private var showSavedSheet = false

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
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 42,
                                style: .continuous
                            )
                        )

                    Text("Capture what held your attention.")
                        .font(.system(size: 16))
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
                            savePhotoObservation(photo)
                        }
                    )
                    .zIndex(2)
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
        .onAppear {
            viewModel.requestCameraPermission()
        }
        .onDisappear {
            viewModel.stopSession()
        }
    }

    // MARK: - Camera Content

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

    // MARK: - Save Photo Observation

    private func savePhotoObservation(_ image: UIImage) {

        guard let draft = draft else {
            print("Missing observation draft")
            return
        }

        do {
            let fileName = try MediaStorageService.shared.savePhoto(image)

            let photoURL = MediaStorageService.shared.mediaURL(fileName: fileName)
            let exists = FileManager.default.fileExists(atPath: photoURL.path)
            let size = ((try? FileManager.default.attributesOfItem(atPath: photoURL.path)[.size]) as? NSNumber)?.intValue ?? 0

            print("Photo saved fileName:", fileName)
            print("Photo exists:", exists)
            print("Photo size:", size)
            print("Photo URL:", photoURL.path)

            guard exists, size > 0 else {
                print("Photo file was not written correctly")
                return
            }

            guard let place = try fetchPlace(with: draft.placeID) else {
                print("Could not find place for sight observation")
                return
            }

            let observation = PlaceObservation(
                sense: draft.sense,
                promptText: draft.prompt,
                mediaFileName: fileName,
                durationSeconds: draft.durationSeconds,
                place: place
            )

            modelContext.insert(observation)
            try modelContext.save()

            print("Sight observation saved in SwiftData with media:", fileName)

            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                showSavedSheet = true
            }

        } catch {
            print("Failed to save sight observation:", error)
        }
    }

    // MARK: - Safe Place Fetch

    private func fetchPlace(with id: UUID) throws -> Place? {
        let descriptor = FetchDescriptor<Place>()
        let places = try modelContext.fetch(descriptor)

        return places.first { place in
            place.id == id
        }
    }
}

// MARK: - Notification

extension Notification.Name {
    static let observationSavedGoHome = Notification.Name("observationSavedGoHome")
}

#Preview {
    CameraView()
}
