//
//  NameEntryView.swift
//  VEIL
//

import SwiftUI

struct NameEntryView: View {
    @Binding var name: String
    let onSubmit: () -> Void

    @FocusState private var isNameFieldFocused: Bool

    @State private var expandWhiteCapsule = false
    @State private var hideTextContent = false
    @State private var hideFieldContent = false
    @State private var isSubmitting = false

    // MARK: - Animation Controls

    private let contentFadeDuration: Double = 0.28
    private let growStartDelay: Double = 0.12
    private let growSpeed: Double = 2.55
    private let growDamping: Double = 0.90

    private let growHoldDuration: Double = 1.0

    private var isNameEmpty: Bool {
        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 22) {

                Text("What’s your name?")
                    .font(.veilTitle)
                    .foregroundColor(Color("TitleColor"))
                    .opacity(hideTextContent ? 0 : 1)
                    .offset(y: hideTextContent ? -8 : 0)
                    .accessibilityAddTraits(.isHeader)

                Text("Your display name for the app experience")
                    .font(.veilBody)
                    .foregroundColor(Color("TitleColor").opacity(0.75))
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .opacity(hideTextContent ? 0 : 1)
                    .offset(y: hideTextContent ? -8 : 0)

                HStack(spacing: 12) {

                    ZStack {
                        Capsule()
                            .fill(expandWhiteCapsule ? Color("BackgroundColor") : Color.white)
                            .frame(
                                width: expandWhiteCapsule ? 1800 : 245,
                                height: expandWhiteCapsule ? 1800 : 48
                            )
                            .animation(
                                .spring(response: growSpeed, dampingFraction: growDamping),
                                value: expandWhiteCapsule
                            )
                            .accessibilityHidden(true)

                        Capsule()
                            .stroke(
                                Color("TitleColor").opacity(expandWhiteCapsule ? 0 : 1),
                                lineWidth: 1
                            )
                            .frame(width: 245, height: 48)
                            .opacity(hideFieldContent ? 0 : 1)
                            .accessibilityHidden(true)

                        TextField(
                            "Enter your name",
                            text: $name,
                            prompt: Text("Enter your name")
                                .foregroundColor(Color("SubtitleColor"))
                        )
                        .font(.veilBody)
                        .foregroundColor(Color("TitleColor"))
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                        .submitLabel(.done)
                        .onSubmit {
                            submitName()
                        }
                        .padding(.horizontal, 12)
                        .frame(width: 245, height: 48)
                        .opacity(hideFieldContent ? 0 : 1)
                        .focused($isNameFieldFocused)
                        .accessibilityLabel("Name")
                        .accessibilityHint("Enter your name to personalize the app experience")
                        .accessibilityValue(name.isEmpty ? "Empty" : name)
                    }
                    .frame(width: 245, height: 48)

                    Button {
                        submitName()
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(Color.white)
                            .frame(width: 34, height: 34)
                            .background(
                                Circle()
                                    .fill(Color(hex: "#212121"))
                            )
                    }
                    .opacity(hideFieldContent ? 0 : (isNameEmpty ? 0.45 : 1))
                    .scaleEffect(hideFieldContent ? 0.85 : 1)
                    .disabled(isNameEmpty || isSubmitting)
                    .accessibilityLabel("Continue")
                    .accessibilityHint(
                        isNameEmpty
                        ? "Enter your name first"
                        : "Saves your name and continues to the app"
                    )
                }
            }
        }
        .frame(width: 310, alignment: .leading)
    }

    private func submitName() {
        guard !isNameEmpty else { return }
        guard !isSubmitting else { return }

        isSubmitting = true
        isNameFieldFocused = false

        withAnimation(.easeInOut(duration: contentFadeDuration)) {
            hideTextContent = true
            hideFieldContent = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + growStartDelay) {
            expandWhiteCapsule = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + growHoldDuration) {
            onSubmit()
        }
    }
}

#Preview {
    ZStack {
        Color("BackgroundColor")
            .ignoresSafeArea()

        NameEntryView(name: .constant("Rahaf")) {}
    }
}
