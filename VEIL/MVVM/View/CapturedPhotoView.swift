//
//  CapturedPhotoView.swift
//  VEIL
//
//  Created by Ghady Al Omar on 07/12/1447 AH.
//
import SwiftUI

struct CapturedPhotoView: View {
    let image: UIImage
    let onDismiss: () -> Void
    let onSave: () -> Void

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let photoSize = min(width - 56, height * 0.43)

            ZStack {
                Color(hex: "F4F4E8")
                    .ignoresSafeArea()

                VStack(spacing: 0) {

                    HStack {
                        Button {
                            onDismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 22, weight: .medium))
                                .foregroundColor(.black)
                                .frame(width: 50, height: 50)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)

                    Spacer(minLength: 46)

                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: photoSize, height: photoSize)
                        .clipShape(RoundedRectangle(cornerRadius: 42, style: .continuous))

                    Text("Observation ready · photo will be saved with this prompt")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Color("SubtitleColor"))
                        .multilineTextAlignment(.center)
                        .padding(.top, 28)

                    Spacer(minLength: 32)

                    HStack(spacing: 54) {
                        Button {
                            onDismiss()
                        } label: {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 26, weight: .regular))
                                .foregroundColor(.black)
                        }

                        Button {
                            onSave()
                        } label: {
                            Image(systemName: "checkmark")
                                .font(.system(size: 34, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(width: 82, height: 82)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.14), radius: 8, x: 0, y: 4)
                        }

                        Button {
                            // share/export later
                        } label: {
                            Image(systemName: "square.and.arrow.down")
                                .font(.system(size: 26, weight: .regular))
                                .foregroundColor(.black)
                        }
                    }

                    Spacer(minLength: 48)
                }
            }
        }
        .transition(.opacity)
    }
}
