//
//  ConfirmModalView.swift
//  VEIL
//

import SwiftUI
import CoreLocation

struct ConfirmModalView: View {

    var address: String
    var radius: CLLocationDistance
    var onBack: () -> Void
    var onContinue: (_ placeName: String, _ activeDays: Int) -> Void

    var chevronOffsetX: CGFloat = -20
    var titleOffsetX: CGFloat = -15

    @State private var placeName: String = ""
    @State private var activeDays: Double = 1

    private var trimmedPlaceName: String {
        placeName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isRadiusAllowed: Bool {
        radius == 5000
    }

    private var canAddPlace: Bool {
        !trimmedPlaceName.isEmpty && isRadiusAllowed
    }

    private var radiusText: String {
        if radius >= 1000 {
            return "\(Int(radius / 1000)) km"
        } else {
            return "\(Int(radius)) m"
        }
    }

    var body: some View {

        VStack(spacing: 20) {

            HStack {

                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                }
                .offset(x: chevronOffsetX)
                .accessibilityLabel("Back")
                .accessibilityHint("Closes place details and returns to the map")

                Text("Place’s details")
                    .font(.veilHeadline)
                    .foregroundColor(.black)
                    .offset(x: titleOffsetX)
                    .accessibilityAddTraits(.isHeader)

                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)

            Text("Name The Place")
                .font(.veilCaption)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 5)
                .padding(.bottom, -8)

            TextField(
                "Enter name",
                text: $placeName,
                prompt: Text("Enter name")
            )
            .font(.veilBody)
            .foregroundColor(.black)
            .padding()
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.white)
            .cornerRadius(25)
            .padding(.horizontal, 5)
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled(true)
            .accessibilityLabel("Place name")
            .accessibilityHint("Enter a name for this place")
            .accessibilityValue(placeName.isEmpty ? "Empty" : placeName)

            Text("Active Period")
                .font(.veilCaption)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 5)
                .padding(.top, -4)
                .accessibilityHidden(true)

            HStack {

                Text("1")
                    .font(.veilCaption)
                    .foregroundColor(.gray)
                    .accessibilityHidden(true)

                Slider(value: $activeDays, in: 1...7, step: 1)
                    .tint(Color("InnerCircle3"))
                    .accessibilityLabel("Active period")
                    .accessibilityValue("\(Int(activeDays)) days")
                    .accessibilityHint("Swipe up or down to change the number of active days")

                Text("7")
                    .font(.veilCaption)
                    .foregroundColor(.gray)
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, 5)
            .padding(.bottom, -8)

            HStack(spacing: 2) {

                Image(systemName: "exclamationmark.circle")
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                    .accessibilityHidden(true)

                Text("This place will stay active for your selected period")
                    .font(.veilSmallCaption)
                    .foregroundColor(.black.opacity(0.8))
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()
            }
            .padding(.horizontal, 5)
            .padding(.top, 4)

            HStack(spacing: 2) {

                Image(systemName: "location.circle")
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                    .accessibilityHidden(true)

                Text("Selected radius: \(radiusText)")
                    .font(.veilSmallCaption)
                    .foregroundColor(.black.opacity(0.8))
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()
            }
            .padding(.horizontal, 5)
            .padding(.top, -8)

            if !isRadiusAllowed {
                HStack(spacing: 2) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 13))
                        .foregroundColor(.red.opacity(0.85))
                        .accessibilityHidden(true)

                    Text("5km Radius.")
                        .font(.veilSmallCaption)
                        .foregroundColor(.red.opacity(0.85))
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer()
                }
                .padding(.horizontal, 5)
                .padding(.top, -8)
            }

            Button(action: {
                onContinue(trimmedPlaceName, Int(activeDays))
            }) {

                Text("Add place")
                    .font(.veilHeadline)
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
            .accessibilityLabel("Add place")
            .accessibilityHint(
                canAddPlace
                ? "Adds this place with an active period of \(Int(activeDays)) days and a radius of \(radiusText)"
                : "Enter a place name first"
            )
        }
        .padding(24)
        .frame(height: isRadiusAllowed ? 390 : 420)
        .background(
            VisualEffectBlur(style: .systemMaterialLight)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .shadow(radius: 10)
                .accessibilityHidden(true)
        )
        .padding(.horizontal, 25)
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(.isModal)
    }
}
