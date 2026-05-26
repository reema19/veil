//
//  PromptQuestionView.swift
//  VEIL
//
//  Created by Ghady Al Omar on 06/12/1447 AH.
//
import SwiftUI

struct PromptQuestionView: View {
    
    @ObservedObject var viewModel: PromptViewModel
    var onDismiss: () -> Void = {}

    @State private var isObservationActive = false
    @State private var seconds = 73

    private var backgroundColor: Color {
        if !isObservationActive {
            return Color("BackgroundColor")
        }

        switch viewModel.currentPrompt.sense {
        case .sight:
            return Color(hex: "EFF0A3").opacity(0.22)
        case .sound:
            return Color(hex: "D8DFE9").opacity(0.42)
        }
    }

    private var formattedTime: String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "00:%02d:%02d", minutes, remainingSeconds)
    }

    var body: some View {
        GeometryReader { geometry in

            let width = geometry.size.width
            let height = geometry.size.height

            let horizontalPadding = width * 0.10
            let headerTopPadding = height * 0.055
            let headerGap = width * 0.055

            let haloSize = min(width * 0.92, 360)
            let questionFontSize = min(max(width * 0.055, 20), 24)
            let questionWidth = min(width * 0.72, 290)

            ZStack {
                backgroundColor
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 0.65), value: isObservationActive)

                VStack(spacing: 0) {

                    // MARK: - Header
                    HStack(alignment: .center, spacing: headerGap) {
                        Button(action: onDismiss) {
                            ZStack {
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 44, height: 44)

                                Image(systemName: "xmark")
                                    .font(.system(size: 19, weight: .medium))
                                    .foregroundColor(Color("TitleColor").opacity(0.72))
                            }
                        }
                        .buttonStyle(.plain)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(viewModel.sessionTitle)
                                .font(.custom("DMSans-Bold", size: 24))
                                .foregroundColor(Color("TitleColor"))

                            Text(viewModel.sessionSubtitle)
                                .font(.custom("DMSans-Regular", size: 12))
                                .foregroundColor(Color("SubtitleColor"))
                        }

                        Spacer()
                    }
                    .padding(.horizontal, horizontalPadding)
                    .padding(.top, headerTopPadding)
                    .opacity(isObservationActive ? 0 : 1)

                    // MARK: - Section Title
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(viewModel.sectionTitle)
                                .font(.custom("DMSans-Bold", size: 20))
                                .foregroundColor(Color("TitleColor"))

                            Text(viewModel.sectionSubtitle)
                                .font(.custom("DMSans-Regular", size: 13))
                                .foregroundColor(Color("SubtitleColor"))
                                .lineSpacing(2)
                        }

                        Spacer()
                    }
                    .padding(.horizontal, horizontalPadding)
                    .padding(.top, height * 0.045)
                    .opacity(isObservationActive ? 0 : 1)

                    // MARK: - Fixed Question Area
                    ZStack {
                        AIHaloView(
                            size: haloSize,
                            expanded: isObservationActive,
                            sense: viewModel.currentPrompt.sense
                        )

                        VStack(spacing: 12) {
                            Text(viewModel.currentPrompt.question)
                                .font(.custom("DMSans-Regular", size: questionFontSize))
                                .foregroundColor(Color("TitleColor"))
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                                .frame(width: questionWidth)
                                .animation(.easeInOut, value: viewModel.currentPromptIndex)

                            if isObservationActive {
                                Text(formattedTime)
                                    .font(.custom("DMSans-Regular", size: 15))
                                    .foregroundColor(Color("SubtitleColor"))
                                    .transition(.opacity)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: height * 0.40)
                    .padding(.top, height * 0.055)

                    // MARK: - Progress
                    VStack(spacing: 10) {
                        HStack(spacing: 10) {
                            ForEach(0..<viewModel.totalPrompts, id: \.self) { i in
                                Circle()
                                    .fill(i == viewModel.currentPromptIndex
                                          ? Color("TitleColor")
                                          : Color("DotInactive"))
                                    .frame(width: 7, height: 7)
                            }
                        }

                        Text(viewModel.promptLabel)
                            .font(.custom("DMSans-Regular", size: 12))
                            .foregroundColor(Color("SubtitleColor"))
                    }
                    .opacity(isObservationActive ? 0 : 1)
                    .padding(.top, 46)

                    Spacer()

                    // MARK: - Actions
                    VStack(spacing: 12) {
                        if !isObservationActive {
                            Button(action: { viewModel.tryAnother() }) {
                                HStack(spacing: 8) {
                                    Image(systemName: viewModel.currentPromptIndex == 0 ? "arrow.clockwise" : "arrow.left")
                                        .font(.system(size: 14, weight: .regular))

                                    Text(viewModel.currentPromptIndex == 0 ? "Try another" : "Back to the previous")
                                        .font(.custom("DMSans-Regular", size: 16))
                                }
                                .foregroundColor(Color("TitleColor"))
                                .frame(width: min(width * 0.58, 234), height: 34)
                                .background(Color.clear)
                                .cornerRadius(40)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 40)
                                        .stroke(Color("TitleColor"), lineWidth: 1)
                                )
                            }
                        }

                        Button(action: {
                            if !isObservationActive {
                                viewModel.stayWithThis()

                                withAnimation(.easeInOut(duration: 0.65)) {
                                    isObservationActive = true
                                }
                            }
                        }) {
                            Text(isObservationActive
                                 ? (viewModel.currentPrompt.sense == .sound ? "Tap to record" : "Tap to capture")
                                 : "Stay with this")
                                .font(.custom("DMSans-Regular", size: 16))
                                .foregroundColor(.white)
                                .frame(width: min(width * 0.58, 234), height: 34)
                                .background(Color.black)
                                .cornerRadius(40)
                        }
                    }
                    .padding(.bottom, height * 0.045)
                }
            }
        }
    }
}
#Preview {
    PromptQuestionView(
        viewModel: PromptViewModel(
            sectionTitle: "Stay with what you see",
            sectionSubtitle: "You don't need to capture everything.\none thing is enough.",
            prompts: [
                SensePrompt(question: "What sound belongs to this place?", sense: .sight),
                SensePrompt(question: "What detail would disappear if you blinked?", sense: .sight)
            ]
        )
    )
}
