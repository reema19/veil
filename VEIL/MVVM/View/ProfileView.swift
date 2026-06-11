//
//  ProfileView.swift
//  VEIL
//
//  Created by Rahaf Alhammadi on 16/12/1447 AH.
//

import SwiftUI
import SwiftData

struct ProfileView: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    @Query(sort: \LocalProfile.createdAt, order: .forward)
    private var profiles: [LocalProfile]

    @Query
    private var places: [Place]

    @Query
    private var observations: [PlaceObservation]

    @AppStorage("whenYouArriveEnabled")
    private var whenYouArriveEnabled = true

    @AppStorage("dontDisturbEnabled")
    private var dontDisturbEnabled = false

    @State private var showEditNameSheet = false
    @State private var editedName = ""

    @State private var showDeleteAccountAlert = false

    private let supportEmail = "we.app.veil@gmail.com"

    private var profile: LocalProfile? {
        profiles.first
    }

    private var displayName: String {
        let name = profile?.displayName.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return name.isEmpty ? "there" : name
    }

    private var avatarInitial: String {
        let trimmed = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        return String(trimmed.prefix(1)).uppercased()
    }

    private var noticingSinceText: String {
        guard let createdAt = profile?.createdAt else {
            return "Noticing since today"
        }

        let formattedDate = createdAt.formatted(
            .dateTime
                .month(.abbreviated)
                .day()
                .year()
        )

        return "Noticing since \(formattedDate)"
    }

    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()

            GeometryReader { geometry in
                let width = geometry.size.width
                let avatarBackgroundSize = min(width * 0.48, 188)
                let avatarSize = min(width * 0.235, 92)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {

                        // MARK: - Header
                        profileHeader

                        // MARK: - Profile Avatar
                        ZStack {
                            Image("xmarkVector")
                                .resizable()
                                .scaledToFit()
                                .frame(
                                    width: avatarBackgroundSize,
                                    height: avatarBackgroundSize
                                )

                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: avatarSize, height: avatarSize)
                                .overlay(
                                    Circle()
                                        .strokeBorder(
                                            Color("TitleColor").opacity(0.08),
                                            lineWidth: 1
                                        )
                                )
                                .shadow(
                                    color: .black.opacity(0.08),
                                    radius: 12,
                                    x: 0,
                                    y: 6
                                )

                            Text(avatarInitial)
                                .font(.system(size: min(avatarSize * 0.42, 38), weight: .bold))
                                .foregroundColor(Color("TitleColor"))
                        }
                        .padding(.top, 32)

                        // MARK: - Name
                        Button {
                            editedName = displayName == "there" ? "" : displayName
                            showEditNameSheet = true
                        } label: {
                            HStack(spacing: 10) {
                                Text(displayName)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(Color("TitleColor"))

                                Image(systemName: "pencil.line")
                                    .font(.system(size: 22, weight: .medium))
                                    .foregroundColor(Color("TitleColor"))
                            }
                            .padding(.horizontal, 36)
                            .frame(height: 52)
                            .background(Color.black.opacity(0.06))
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 14)

                        Text(noticingSinceText)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(Color("SubtitleColor"))
                            .padding(.top, 12)

                        // MARK: - Notification Section
                        VStack(alignment: .leading, spacing: 18) {
                            Text("Notification")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color("TitleColor"))
                                .padding(.leading, 14)

                            ProfileToggleRow(
                                icon: "position-icon",
                                title: "When you arrive",
                                isOn: $whenYouArriveEnabled
                            )
                            .onChange(of: whenYouArriveEnabled) { _, newValue in
                                if newValue {
                                    LocationReminderManager.shared.requestAlwaysLocationPermission()
                                } else {
                                    LocationReminderManager.shared.stopAllVEILPlaceMonitoring()
                                }
                            }

                            Text("Receive a notification when you enter the location.")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(Color("SubtitleColor"))
                                .padding(.leading, 6)

                            ProfileToggleRow(
                                icon: "Don’t-disturb",
                                title: "Morning reminder",
                                isOn: $dontDisturbEnabled
                            )
                            .onChange(of: dontDisturbEnabled) { _, newValue in
                                handleMorningReminderToggleChanged(newValue)
                            }

                            Text("Receive a gentle reminder every morning at 9:00 AM.")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(Color("SubtitleColor"))
                                .padding(.leading, 6)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 46)

                        // MARK: - About Section
                        VStack(alignment: .leading, spacing: 18) {
                            Text("About")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color("TitleColor"))
                                .padding(.leading, 14)

                            Button {
                                openSupportEmail()
                            } label: {
                                ProfileAboutRow(
                                    icon: "questionmark",
                                    title: "Help & support"
                                )
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 34)

                        Button {
                            showDeleteAccountAlert = true
                        } label: {
                            Text("Delete account")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color("SubtitleColor"))
                                .underline()
                        }
                        .padding(.top, 60)
                        .padding(.bottom, 62)
                    }
                    .padding(.top, 20)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showEditNameSheet) {
            EditProfileNameSheet(
                name: $editedName,
                onCancel: {
                    showEditNameSheet = false
                },
                onSave: {
                    saveName()
                }
            )
            .presentationDetents([.height(260)])
            .presentationDragIndicator(.visible)
        }
        .alert("Delete account?", isPresented: $showDeleteAccountAlert) {
            Button("Cancel", role: .cancel) { }

            Button("Delete", role: .destructive) {
                deleteAccount()
            }
        } message: {
            Text("This will delete your profile, saved places, observations, and cancel VEIL notifications. This action cannot be undone.")
        }
    }

    private var profileHeader: some View {
        HStack(alignment: .center, spacing: 16) {

            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 23, weight: .medium))
                    .foregroundColor(Color("TitleColor"))
                    .frame(width: 58, height: 58)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .strokeBorder(
                                Color("TitleColor").opacity(0.08),
                                lineWidth: 1
                            )
                    )
                    .shadow(
                        color: .black.opacity(0.08),
                        radius: 12,
                        x: 0,
                        y: 6
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Back")

            Text("Profile")
                .font(.custom("DMSans-Bold", size: 24, relativeTo: .title2))
                .foregroundColor(Color("TitleColor"))
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .accessibilityAddTraits(.isHeader)

            Color.clear
                .frame(width: 58, height: 58)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
    }

    private func handleMorningReminderToggleChanged(_ isEnabled: Bool) {
        if isEnabled {
            NotificationManager.shared.checkPermissionStatus { status in
                switch status {
                case .authorized, .provisional, .ephemeral:
                    NotificationManager.shared.scheduleMorningReminder()

                case .notDetermined:
                    NotificationManager.shared.requestPermission { granted in
                        if granted {
                            NotificationManager.shared.scheduleMorningReminder()
                        } else {
                            dontDisturbEnabled = false
                        }
                    }

                case .denied:
                    dontDisturbEnabled = false

                @unknown default:
                    dontDisturbEnabled = false
                }
            }
        } else {
            NotificationManager.shared.cancelMorningReminder()
        }
    }

    private func openSupportEmail() {
        let subject = "VEIL Help & Support"

        guard let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "mailto:\(supportEmail)?subject=\(encodedSubject)") else {
            return
        }

        openURL(url)
    }

    private func saveName() {
        let trimmedName = editedName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        if let profile {
            profile.updateDisplayName(trimmedName)
        } else {
            let newProfile = LocalProfile(displayName: trimmedName)
            modelContext.insert(newProfile)
        }

        do {
            try modelContext.save()
            showEditNameSheet = false
        } catch {
            print("Failed to update profile name:", error)
        }
    }

    private func deleteAccount() {
        // Stop all VEIL notifications and location monitoring first.
        NotificationManager.shared.cancelMorningReminder()
        LocationReminderManager.shared.stopAllVEILPlaceMonitoring()

        // Reset profile toggles.
        whenYouArriveEnabled = false
        dontDisturbEnabled = false

        // Delete observations first.
        for observation in observations {
            modelContext.delete(observation)
        }

        // Delete saved places.
        for place in places {
            modelContext.delete(place)
        }

        // Delete local profile.
        for profile in profiles {
            modelContext.delete(profile)
        }

        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to delete account:", error)
        }
    }
}

private struct EditProfileNameSheet: View {

    @Binding var name: String

    let onCancel: () -> Void
    let onSave: () -> Void

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(spacing: 18) {
            Text("Edit name")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color("TitleColor"))

            TextField("Enter your name", text: $name)
                .font(.system(size: 16, weight: .regular))
                .padding()
                .frame(height: 52)
                .background(Color.black.opacity(0.06))
                .clipShape(Capsule())
                .padding(.horizontal, 24)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled(true)

            HStack(spacing: 12) {
                Button(action: onCancel) {
                    Text("Cancel")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(Color("TitleColor"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.black.opacity(0.06))
                        .clipShape(Capsule())
                }

                Button(action: onSave) {
                    Text("Save")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.black.opacity(canSave ? 1 : 0.35))
                        .clipShape(Capsule())
                }
                .disabled(!canSave)
            }
            .padding(.horizontal, 24)
        }
        .padding(.top, 24)
    }
}

private struct ProfileToggleRow: View {

    let icon: String
    let title: String

    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.black.opacity(0.06))
                    .frame(width: 42, height: 42)

                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 28)
            }

            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color("TitleColor"))

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color(hex: "34C759"))
        }
        .padding(.horizontal, 22)
        .frame(height: 72)
        .background(.white)
        .cornerRadius(30)
    }
}

private struct ProfileAboutRow: View {

    let icon: String
    let title: String

    var body: some View {
        HStack(spacing: 20) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.black.opacity(0.06))
                    .frame(width: 42, height: 42)

                Image(systemName: icon)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(Color("TitleColor"))
            }

            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color("TitleColor"))

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color("SubtitleColor"))
        }
        .padding(.horizontal, 22)
        .frame(height: 72)
        .background(.white)
        .cornerRadius(38)
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .modelContainer(for: [
                LocalProfile.self,
                Place.self,
                PlaceObservation.self
            ], inMemory: true)
    }
}
