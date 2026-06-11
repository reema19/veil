//
//  PromptQuestionView.swift
//  VEIL
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

    @State private var revealCount = 0
    @State private var isTypingPrompt = false
    @State private var hasPlayedInitialTyping = false
    @State private var typingTask: Task<Void, Never>?

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

    private var shouldAnimateHalo: Bool {
        viewModel.isLoadingPrompts || isTypingPrompt
    }

    var body: some View {
        GeometryReader { geometry in

            let width = geometry.size.width
            let height = geometry.size.height

            let headerHorizontalPadding: CGFloat = 18
            let contentHorizontalPadding: CGFloat = 42

            let haloSize = min(width * 0.92, 330)
            let questionFontSize = min(max(width * 0.055, 20), 24)
            let questionWidth = min(width * 0.72, 290)

            ZStack {
                backgroundColor
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        finishTypingImmediately()
                    }
                    .animation(.easeInOut(duration: 0.65), value: isObservationActive)

                VStack(spacing: 0) {

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
                                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
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

                    ZStack {
                        AIHaloView(
                            size: haloSize,
                            expanded: isObservationActive,
                            sense: viewModel.currentPrompt.sense,
                            isThinking: shouldAnimateHalo
                        )

                        VStack(spacing: 12) {
                            if viewModel.isLoadingPrompts {
                                SlowmoPromptLoader()
                                    .frame(width: 70, height: 70)
                                    .transition(.opacity)
                            } else {
                                TypingPromptText(
                                    text: viewModel.currentPrompt.question,
                                    revealCount: revealCount,
                                    fontSize: questionFontSize,
                                    width: questionWidth
                                )
                            }

                            if isObservationActive {
                                Text(formattedTime)
                                    .font(.custom("DMSans-Regular", size: 15))
                                    .foregroundColor(Color("SubtitleColor"))
                                    .transition(.opacity)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: height * 0.34)
                    .padding(.top, height * 0.119)

                    VStack(spacing: 10) {
                        if !viewModel.isLoadingPrompts {
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
                    }
                    .opacity(isObservationActive ? 0 : 1)
                    .padding(.top, 54)

                    Spacer()

                    VStack(spacing: 12) {
                        if !isObservationActive {
                            Button(action: {
                                viewModel.tryAnother()
                            }) {
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
                            .disabled(viewModel.isLoadingPrompts || isTypingPrompt)
                            .opacity((viewModel.isLoadingPrompts || isTypingPrompt) ? 0.45 : 1)
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
                        .disabled(viewModel.isLoadingPrompts || isTypingPrompt)
                        .opacity((viewModel.isLoadingPrompts || isTypingPrompt) ? 0.45 : 1)
                    }
                    .padding(.bottom, height * 0.015)
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
        .onReceive(NotificationCenter.default.publisher(for: .observationSavedGoHome)) { _ in
            dismiss()
        }
        .onChange(of: viewModel.isLoadingPrompts) { _, isLoading in
            if !isLoading && !hasPlayedInitialTyping {
                hasPlayedInitialTyping = true
                startTypingPrompt(viewModel.currentPrompt.question)
            }
        }
        .onChange(of: viewModel.currentPromptIndex) { _, _ in
            if !viewModel.isLoadingPrompts {
                showPromptImmediately(viewModel.currentPrompt.question)
            }
        }
        .onDisappear {
            typingTask?.cancel()
            stopTimer()
        }
    }

    private func startTypingPrompt(_ prompt: String) {
        typingTask?.cancel()

        revealCount = 0
        isTypingPrompt = true

        typingTask = Task { @MainActor in
            let characters = Array(prompt)

            for index in characters.indices {
                if Task.isCancelled { return }

                revealCount = index + 1

                try? await Task.sleep(nanoseconds: 145_000_000)
            }

            if !Task.isCancelled {
                isTypingPrompt = false
            }
        }
    }

    private func showPromptImmediately(_ prompt: String) {
        typingTask?.cancel()
        revealCount = Array(prompt).count
        isTypingPrompt = false
    }

    private func finishTypingImmediately() {
        guard isTypingPrompt else { return }

        typingTask?.cancel()
        revealCount = Array(viewModel.currentPrompt.question).count
        isTypingPrompt = false
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

private struct TypingPromptText: View {
    let text: String
    let revealCount: Int
    let fontSize: CGFloat
    let width: CGFloat

    private var visibleText: String {
        String(Array(text).prefix(revealCount))
    }

    private var remainingText: String {
        String(Array(text).dropFirst(revealCount))
    }

    var body: some View {
        (
            Text(visibleText)
                .foregroundColor(Color("TitleColor"))
            +
            Text(remainingText)
                .foregroundColor(Color(hex: "9A9A9A"))
        )
        .font(.custom("DMSans-Regular", size: fontSize))
        .multilineTextAlignment(.center)
        .lineSpacing(4)
        .frame(width: width)
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: width)
        .lineLimit(nil)
        
    }
}

private struct SlowmoPromptLoader: View {

    @State private var rotation: Double = 0
    @State private var opacity: Double = 0.32
    @State private var scale: CGFloat = 0.96

    var body: some View {
        Image(systemName: "slowmo")
            .font(.system(size: 42, weight: .regular))
            .foregroundColor(Color("TitleColor").opacity(opacity))
            .rotationEffect(.degrees(rotation))
            .scaleEffect(scale)
            .onAppear {
                withAnimation(.linear(duration: 2.2).repeatForever(autoreverses: false)) {
                    rotation = 360
                }

                withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                    opacity = 0.82
                    scale = 1.05
                }
            }
    }
}
