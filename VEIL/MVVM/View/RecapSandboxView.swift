//
//  RecapSandboxView.swift
//  VEIL
//
//  Created by reema aljohani on 6/6/26.
//

import SwiftUI

struct RecapSandboxView: View {

    @State private var pageIndex = 0
    private let totalPages = 5

    var body: some View {
        ZStack {
            Color(hex: "F7F7F2").ignoresSafeArea()

            TabView(selection: $pageIndex) {
                RecapIntroPage().tag(0)
                RecapPhotoPage().tag(1)
                RecapAudioPage().tag(2)
                RecapPresencePage().tag(3)
                RecapEndPage().tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            VStack {
                RecapProgressBar(currentIndex: pageIndex, total: totalPages)
                    .padding(.horizontal, 28)
                    .padding(.top, 60)

                Spacer()
            }
        }
    }
}

// MARK: - Progress

private struct RecapProgressBar: View {
    let currentIndex: Int
    let total: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<total, id: \.self) { index in
                Capsule()
                    .fill(index <= currentIndex ? Color(hex: "2B2B2B") : Color.black.opacity(0.10))
                    .frame(height: 3)
            }
        }
    }
}

// MARK: - Intro

private struct RecapIntroPage: View {
    var body: some View {
        ZStack {
            recapSoftBackground

            VStack(spacing: 8) {
                Text("YOUR")
                    .font(.custom("DMSans-Bold", size: 13))
                    .foregroundColor(Color(hex: "9DB791"))

                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("7")
                    Text("days").italic()
                }
                .font(.system(size: 54, weight: .light, design: .serif))
                .foregroundColor(Color(hex: "252525"))

                Text("at Morning Café")
                    .font(.system(size: 18, weight: .regular, design: .serif))
                    .italic()

                Spacer().frame(height: 250)

                Text("tap to continue")
                    .font(.custom("DMSans-Regular", size: 11))
                    .foregroundColor(Color(hex: "6F6F6F"))
            }
            .padding(.top, 280)
        }
    }
}

// MARK: - Photo

private struct RecapPhotoPage: View {
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [
                    Color(hex: "7C2F1D"),
                    Color(hex: "C8792A"),
                    Color(hex: "1F1B1B")
                ],
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )
            .ignoresSafeArea()

            BottomTextBlur()

            VStack(alignment: .leading, spacing: 6) {
                Text("at Morning Café")
                    .font(.system(size: 17, weight: .regular, design: .serif))
                    .foregroundColor(.white)

                Text("11-10-2025")
                    .font(.custom("DMSans-Regular", size: 13))
                    .foregroundColor(.white.opacity(0.9))

                Spacer()

                Text("“What’s the one colour you’d take home today?”")
                    .font(.custom("DMSans-Bold", size: 22))
                    .foregroundColor(.white)
                    .lineSpacing(3)
                    .padding(.bottom, 34)
            }
            .padding(.horizontal, 28)
            .padding(.top, 105)
        }
    }
}

// MARK: - Audio

private struct RecapAudioPage: View {

    @State private var progress: CGFloat = 0
    @State private var isPlaying = false
    @State private var didAutoPlay = false
    @State private var rotation: Double = 0
    @State private var timer: Timer?

    private let duration: CGFloat = 5

    var body: some View {
        ZStack {
            recapSoftBackground

            BottomTextBlur()

            VStack(alignment: .leading, spacing: 0) {
                Text("at Morning Café")
                    .font(.system(size: 17, weight: .regular, design: .serif))
                    .foregroundColor(Color(hex: "252525"))

                Text("11-10-2025")
                    .font(.custom("DMSans-Regular", size: 13))
                    .foregroundColor(Color(hex: "252525"))
                    .padding(.top, 4)

                Spacer()

                VStack(spacing: 46) {
                    VinylRecord(
                        rotation: rotation,
                        isPlaying: isPlaying,
                        onNeedleTap: {
                            replay()
                        }
                    )
                    .frame(width: 270, height: 270)

                    VStack(spacing: 18) {
                        Slider(value: $progress, in: 0...1)
                            .tint(Color(hex: "EFF0A3"))

                        HStack {
                            Text("0:14")

                            Spacer()

                            Button {
                                isPlaying ? pause() : replay()
                            } label: {
                                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.black)
                            }

                            Spacer()

                            Text("0:38")
                        }
                        .font(.custom("DMSans-Regular", size: 18))
                        .foregroundColor(Color(hex: "252525"))
                    }
                }
                .frame(maxWidth: .infinity)

                Spacer()

                Text("“What’s the deepest sound you’d take home today?”")
                    .font(.custom("DMSans-Bold", size: 22))
                    .foregroundColor(.white)
                    .lineSpacing(3)
                    .padding(.bottom, 34)
            }
            .padding(.horizontal, 28)
            .padding(.top, 105)
        }
        .onAppear {
            guard !didAutoPlay else { return }
            didAutoPlay = true
            replay()
        }
        .onDisappear {
            stop()
        }
    }

    private func replay() {
        stop()

        progress = 0
        rotation = 0
        isPlaying = true

        withAnimation(.linear(duration: 1.15).repeatForever(autoreverses: false)) {
            rotation = 360
        }

        let start = Date()
        let timer = Timer(timeInterval: 0.02, repeats: true) { timer in
            let elapsed = CGFloat(Date().timeIntervalSince(start))
            progress = min(elapsed / duration, 1)

            if progress >= 1 {
                isPlaying = false
                timer.invalidate()
            }
        }

        self.timer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    private func pause() {
        isPlaying = false
        timer?.invalidate()
        timer = nil
    }

    private func stop() {
        isPlaying = false
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Vinyl

private struct VinylRecord: View {
    let rotation: Double
    let isPlaying: Bool
    let onNeedleTap: () -> Void

    var body: some View {
        ZStack {
            ZStack {
                Circle()
                    .fill(Color(hex: "111111"))

                ForEach(0..<10, id: \.self) { index in
                    Circle()
                        .stroke(Color.white.opacity(0.055), lineWidth: 2)
                        .padding(CGFloat(index) * 12)
                }

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: "1A1A1A"),
                                Color(hex: "EFF0A3").opacity(0.95),
                                Color(hex: "EFF0A3").opacity(0.55),
                                Color(hex: "111111")
                            ],
                            center: .center,
                            startRadius: 3,
                            endRadius: 74
                        )
                    )
                    .frame(width: 116, height: 116)

                Circle()
                    .fill(Color(hex: "1E1E1E"))
                    .frame(width: 18, height: 18)

                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 4, height: 86)
                    .offset(y: -72)
            }
            .rotationEffect(.degrees(rotation))

            ZStack {
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "D7D7D7"),
                                Color(hex: "9F9F9F")
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 94, height: 12)
                    .rotationEffect(.degrees(-38))
                    .shadow(color: .black.opacity(0.22), radius: 5, x: 0, y: 3)

                Circle()
                    .fill(Color(hex: "B8B8B8"))
                    .frame(width: 34, height: 34)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.45), lineWidth: 3)
                    )
                    .offset(x: 48, y: -39)

                Circle()
                    .fill(isPlaying ? Color(hex: "EFF0A3") : Color.white.opacity(0.9))
                    .frame(width: 10, height: 10)
                    .offset(x: -38, y: 30)
                    .shadow(color: Color(hex: "EFF0A3").opacity(isPlaying ? 0.8 : 0), radius: 8)
            }
            .offset(x: 86, y: -76)
            .contentShape(Rectangle())
            .onTapGesture {
                onNeedleTap()
            }
        }
    }
}

// MARK: - Presence

private struct RecapPresencePage: View {
    var body: some View {
        ZStack {
            recapSoftBackground

            VStack(spacing: 16) {
                Text("YOU WERE PRESENT FOR")
                    .font(.custom("DMSans-Bold", size: 11))
                    .foregroundColor(Color(hex: "6F6F6F"))

                Text("12:47")
                    .font(.system(size: 54, weight: .light, design: .serif))
                    .italic()
                    .foregroundColor(Color(hex: "252525"))

                Text("at My garden.")
                    .font(.system(size: 15, weight: .regular, design: .serif))
                    .italic()
                    .foregroundColor(Color(hex: "6F6F6F"))
            }
        }
    }
}

// MARK: - End

private struct RecapEndPage: View {
    var body: some View {
        ZStack {
            Color(hex: "F7F7F2").ignoresSafeArea()

            VStack(spacing: 18) {
                Circle()
                    .fill(Color(hex: "EFF0A3").opacity(0.7))
                    .frame(width: 78, height: 78)
                    .blur(radius: 4)
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.black)
                    )

                Text("You’ve watched this place.")
                    .font(.custom("DMSans-Bold", size: 25))
                    .foregroundColor(Color(hex: "252525"))

                Text("These moments will stay in your archive.")
                    .font(.custom("DMSans-Regular", size: 15))
                    .foregroundColor(Color(hex: "6F6F6F"))
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)
        }
    }
}

// MARK: - Shared Views

private var recapSoftBackground: some View {
    LinearGradient(
        colors: [
            Color(hex: "F7F7F2"),
            Color(hex: "D8DFE9").opacity(0.62),
            Color(hex: "EFF0A3").opacity(0.32)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
    .ignoresSafeArea()
}

private struct BottomTextBlur: View {
    var body: some View {
        VStack {
            Spacer()

            LinearGradient(
                colors: [
                    Color.black.opacity(0.0),
                    Color.black.opacity(0.22),
                    Color.black.opacity(0.60)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 430)
            .background(.ultraThinMaterial.opacity(0.18))
            .clipShape(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
            )
            .blur(radius: 0.2)
            .ignoresSafeArea(edges: .bottom)
        }
    }
}

#Preview {
    RecapSandboxView()
}
