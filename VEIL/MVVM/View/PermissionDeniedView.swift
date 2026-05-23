//
//  PermissionDeniedView.swift
//  VEIL
//
//  Created by Ghady Al Omar on 07/12/1447 AH.
//
import SwiftUI

struct PermissionDeniedView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 36)
                .fill(Color(white: 0.847))

            VStack(spacing: 16) {
                Image(systemName: "camera.slash.fill")
                    .font(.system(size: 40))
                    .foregroundColor(Color(white: 0.55))

                Text("Camera Access Required")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(white: 0.3))

                Text("Please allow camera access from Settings to continue.")
                    .font(.system(size: 13))
                    .foregroundColor(Color(white: 0.5))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Text("Open Settings")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(Color(white: 0.31))
                        .clipShape(Capsule())
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
