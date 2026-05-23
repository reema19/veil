//
//  ChooseSceneView.swift
//  VEIL
//
//  Created by Ghady Al Omar on 06/12/1447 AH.
//
import SwiftUI

struct ChooseSceneView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ChooseSceneViewModel()

    var body: some View {
        ZStack {
            Color("BackgroundColor").ignoresSafeArea()

            VStack(spacing: 0) {
                // Nav bar
                HStack {
                    Button(action: { dismiss() }) {
                        ZStack {
                            Circle()
                                .fill(.white)
                                .frame(width: 44, height: 44)
                                .shadow(color: .black.opacity(0.10), radius: 16, x: 0, y: 4)
                            Image(systemName: "chevron.left")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Color(hex: "#1A1A1A"))
                        }
                    }
                    Spacer()
                    Text(viewModel.sceneTitle)
                        .font(.custom("DMSans-SemiBold", size: 24))
                        .foregroundColor(Color(hex: "#161719"))
                    Spacer()
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, 20)
                .padding(.top, 6)
                .padding(.bottom, 8)

                VStack(alignment: .leading, spacing: 0) {
                    Text("which sense will guide you today ?")
                        .font(.custom("DMSans-Bold", size: 20))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 60)
                        .padding(.bottom, 32)

                    VStack(spacing: 30) {
                        ForEach(viewModel.senses, id: \.self) { sense in
                            SenseCardView(sense: sense)
                                .onTapGesture { viewModel.didSelect(sense: sense) }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
                }
                .padding(.horizontal, 24)

                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
}
#Preview {
    ChooseSceneView()
}
