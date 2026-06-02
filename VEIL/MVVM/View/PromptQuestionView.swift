//
//  PromptQuestionView.swift
//  VEIL
//
//  Created by Ghady Al Omar on 06/12/1447 AH.
//
import SwiftUI
import AVFoundation

struct PromptQuestionView: View {
    
    let place: Place
    @ObservedObject var viewModel: PromptViewModel
    var onDismiss: () -> Void = {}

    @Environment(\.dismiss) private var dismiss

    @State private var isObservationActive = false
    @State private var seconds = 0
    @State private var timer: Timer?
    @State private var cameraDraft: ObservationDraft?
    @State private var audioDraft: ObservationDraft?
    @State private var showMicrophonePermissionAlert = false

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

            let headerHorizontalPadding: CGFloat = 18
            let contentHorizontalPadding: CGFloat = 42

            let haloSize = min(width * 0.92, 360)
            let questionFontSize = min(max(width * 0.055, 20), 24)
            let questionWidth = min(width * 0.72, 290)

            ZStack {
                backgroundColor
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 0.65), value: isObservationActive)

                VStack(spacing: 0) {

                    // MARK: - Header
                    HStack(spacing: 12) {

                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 22, weight: .medium))
                                .foregroundColor(Color("TitleColor"))
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

                        VStack(alignment: .leading, spacing: 2) {
                            Text(viewModel.sessionTitle)
                                .font(.custom("DMSans-Bold", size: 24))
                                .foregroundColor(Color("TitleColor"))
                                .lineLimit(1)

                            Text(viewModel.sessionSubtitle)
                                .font(.custom("DMSans-Regular", size: 12))
                                .foregroundColor(Color("SubtitleColor"))
                        }

                        Spacer()
                    }
                    .padding(.horizontal, headerHorizontalPadding)
                    .padding(.top, 20)
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
                    .padding(.horizontal, contentHorizontalPadding)
                    .padding(.top, 52)
                    .opacity(isObservationActive ? 0 : 1)

                    // MARK: - Question Area
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
                    .frame(height: height * 0.38)
                    .padding(.top, height * 0.045)

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
                    .padding(.top, 34)

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
                                .frame(width: min(width * 0.58, 234), height: 36)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 40)
                                        .stroke(Color("TitleColor"), lineWidth: 1)
                                )
                            }
                        }

                        Button {
                            if !isObservationActive {
                                viewModel.stayWithThis()

                                withAnimation(.easeInOut(duration: 0.65)) {
                                    isObservationActive = true
                                }

                                startTimer()
                            } else {
                                let draft = ObservationDraft(
                                    placeID: place.id,
                                    placeTitle: place.name,
                                    placeCurrentDay: place.currentDay,
                                    placeTotalDays: place.activeDays,
                                    sense: viewModel.currentPrompt.sense,
                                    prompt: viewModel.currentPrompt.question,
                                    durationSeconds: seconds
                                )

                                switch viewModel.currentPrompt.sense {
                                case .sight:
                                    cameraDraft = draft

                                case .sound:
                                    requestMicrophonePermission {
                                        audioDraft = draft
                                    }
                                }
                            }
                        } label: {
                            Text(isObservationActive
                                 ? (viewModel.currentPrompt.sense == .sound ? "Tap to record" : "Tap to capture")
                                 : "Stay with this")
                                .font(.custom("DMSans-Regular", size: 16))
                                .foregroundColor(.white)
                                .frame(width: min(width * 0.58, 234), height: 36)
                                .background(Color.black)
                                .cornerRadius(40)
                        }
                    }
                    .padding(.bottom, height * 0.045)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(item: $cameraDraft) { draft in
            CameraView(draft: draft)
        }
        .navigationDestination(item: $audioDraft) { draft in
            AudioRecorderView(draft: draft)
        }
        .alert("Microphone Access Needed", isPresented: $showMicrophonePermissionAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please allow microphone access from Settings so you can record what you hear.")
        }
        .onDisappear {
            stopTimer()
        }
    }

    private func startTimer() {
        timer?.invalidate()
        seconds = 0

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            seconds += 1
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func requestMicrophonePermission(onGranted: @escaping () -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                if granted {
                    onGranted()
                } else {
                    showMicrophonePermissionAlert = true
                }
            }
        }
    }
}
/*#Preview {
    PromptQuestionView(
        place: WatchingPlace(
            title: "Morning café",
            currentDay: 4,
            totalDays: 7,
            tint: Color(red: 0.93, green: 0.92, blue: 0.58)
        ),
        viewModel: PromptViewModel(
            sectionTitle: "Stay with what you see",
            sectionSubtitle: "You don't need to capture everything.\none thing is enough.",
            prompts: [
                SensePrompt(question: "What detail would you keep from here?", sense: .sight),
                SensePrompt(question: "What would disappear if you blinked?", sense: .sight)
            ]
        )
    )
}
*/
