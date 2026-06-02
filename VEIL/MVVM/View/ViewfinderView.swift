//
//  ViewfinderView.swift
//  VEIL
//
//  Created by Ghady Al Omar on 07/12/1447 AH.
//
import SwiftUI

struct ViewfinderView: View {
    @ObservedObject var viewModel: CameraViewModel

    var body: some View {
        ZStack {
            CameraPreview(session: viewModel.session)
                .clipShape(RoundedRectangle(cornerRadius: 42, style: .continuous))

            RoundedRectangle(cornerRadius: 42, style: .continuous)
                .stroke(Color.white.opacity(0.38), lineWidth: 1.2)

            VStack {
                HStack {
                    Spacer()

                    Button {
                        viewModel.toggleFlash()
                    } label: {
                        Image(systemName: viewModel.isFlashOn ? "bolt.fill" : "bolt.slash")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(viewModel.isFlashOn ? Color(red: 0.91, green: 0.78, blue: 0.25) : .white.opacity(0.82))
                            .frame(width: 34, height: 34)
                            .background(
                                Circle()
                                    .fill(Color.black.opacity(0.28))
                            )
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                HStack(spacing: 8) {
                    ForEach(ZoomLevel.allCases, id: \.self) { level in
                        ZoomButton(
                            label: level.rawValue,
                            isSelected: viewModel.selectedZoom == level
                        ) {
                            viewModel.setZoom(level)
                        }
                    }
                }
            }
            .padding(18)
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)
    }
}
