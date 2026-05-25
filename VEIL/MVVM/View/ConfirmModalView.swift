//
//  ConfirmModalView.swift
//  VEIL
//

import SwiftUI

struct ConfirmModalView: View {

    var address: String
    var onBack: () -> Void
    var onContinue: (_ placeName: String, _ activeDays: Int) -> Void

    // MARK: - Adjust Horizontal Positions
    var chevronOffsetX: CGFloat = -20
    var titleOffsetX: CGFloat = -15

    @State private var placeName: String = ""
    @State private var activeDays: Double = 1

    private var trimmedPlaceName: String {
        placeName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canAddPlace: Bool {
        !trimmedPlaceName.isEmpty
    }

    var body: some View {

        VStack(spacing: 20) {

            // MARK: - Header
            HStack {

                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                }
                .offset(x: chevronOffsetX)

                Text("Place’s details")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                    .offset(x: titleOffsetX)

                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)

            // MARK: - Place Name Label
            Text("Name The Place")
                .font(.system(size: 13))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 5)
                .padding(.bottom, -8)

            // MARK: - Place Name TextField
            TextField("Enter name", text: $placeName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.black)
                .padding()
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.white)
                .cornerRadius(25)
                .padding(.horizontal, 5)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled(true)

            // MARK: - Active Period Label
            Text("Active Period ( \(Int(activeDays)) days )")
                .font(.system(size: 13))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 5)
                .padding(.top, -4)

            // MARK: - Active Period Slider
            HStack {

                Text("1")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)

                Slider(value: $activeDays, in: 1...7, step: 1)
                    .tint(Color("InnerCircle3"))

                Text("7")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 5)
            .padding(.bottom, -8)

            // MARK: - Helper Text
            HStack(spacing: 2) {

                Image(systemName: "exclamationmark.circle")
                    .font(.system(size: 14))
                    .foregroundColor(.black)

                Text("This place will stay active for your selected period")
                    .font(.system(size: 10))
                    .foregroundColor(.black.opacity(0.8))
                    .lineLimit(1)

                Spacer()
            }
            .padding(.horizontal, 5)
            .padding(.top, 4)

            // MARK: - Add Place Button
            Button(action: {
                onContinue(trimmedPlaceName, Int(activeDays))
            }) {

                Text("Add place")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: 150)
                    .frame(height: 58)
                    .background(Color.black.opacity(canAddPlace ? 0.92 : 0.35))
                    .clipShape(Capsule())
                    .padding(.horizontal, 8)
            }
            .disabled(!canAddPlace)
            .padding(.top, 6)
            .padding(.bottom, 10)
        }
        .padding(24)
        .frame(height: 360)
        .background(
            VisualEffectBlur(style: .systemMaterialLight)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .shadow(radius: 10)
        )
        .padding(.horizontal, 25)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.2).ignoresSafeArea()

        ConfirmModalView(
            address: "Riyadh, Saudi Arabia",
            onBack: {},
            onContinue: { placeName, activeDays in
                print(placeName)
                print(activeDays)
            }
        )
    }
}
