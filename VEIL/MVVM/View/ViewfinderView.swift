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
                .clipShape(RoundedRectangle(cornerRadius: 36))

            VStack {
                Spacer()
                HStack(spacing: 8) {
                    ForEach(ZoomLevel.allCases, id: \.self) { level in
                        ZoomButton(label: level.rawValue, isSelected: viewModel.selectedZoom == level) {
                            viewModel.setZoom(level)
                        }
                    }
                }
                .padding(.bottom, 20)
            }
            .padding(22)
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)
    }
}
