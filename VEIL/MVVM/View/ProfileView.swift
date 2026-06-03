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

    @Query(sort: \LocalProfile.createdAt, order: .forward)
    private var profiles: [LocalProfile]

    @State private var whenYouArriveEnabled = true
    @State private var dontDisturbEnabled = true

    @State private var showEditNameSheet = false
    @State private var editedName = ""

    private var profile: LocalProfile? {
        profiles.first
    }

    private var displayName: String {
        let name = profile?.displayName.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return name.isEmpty ? "there" : name
    }

    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    // MARK: - Header
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

                        Text("Profile")
                            .font(.custom("DMSans-SemiBold", size: 24))
                            .foregroundColor(.black)

                        Spacer()

                        Color.clear
                            .frame(width: 50, height: 50)
                    }
                    .padding(.horizontal, 28)
                    .padding(.top, 5)
                    // MARK: - Profile Icon
                    ZStack {
                        Image("xmarkVector")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 188, height: 188)

                        Image(systemName: "person.crop.circle")
                            .font(.system(size: 27, weight: .medium))
                            .foregroundColor(Color("TitleColor"))
                            .frame(width: 84, height: 84)
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
                    .padding(.top, 5)

                    // MARK: - Name
                    Button {
                        editedName = displayName == "there" ? "" : displayName
                        showEditNameSheet = true
                    } label: {
                        HStack(spacing: 10) {
                            Text(displayName)
                                .font(.custom("DMSans-SemiBold", size: 24))
                                .foregroundColor(.black)

                            Image(systemName: "pencil.line")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(.black)
                        }
                        .padding(.horizontal, 36)
                        .frame(height: 52)
                        .background(Color.black.opacity(0.06))
                        .cornerRadius(40)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 14)

                    Text("Noticing since April 22")
                        .font(.custom("DMSans-Regular", size: 16))
                        .foregroundColor(Color(hex: "6F6F6F"))
                        .padding(.top, 12)

                    // MARK: - Notification Section
                    VStack(alignment: .leading, spacing: 18) {
                        Text("Notification")
                            .font(.custom("DMSans-SemiBold", size: 20))
                            .foregroundColor(Color(hex: "252525"))
                            .padding(.leading, 14)

                        ProfileToggleRow(
                            icon: "position-icon",
                            title: "When you arrive",
                            isOn: $whenYouArriveEnabled
                        )

                        Text("Receive a notification when you Enter the location")
                            .font(.custom("DMSans-Regular", size: 14))
                            .foregroundColor(Color(hex: "6F6F6F"))
                            .padding(.leading, 6)

                        ProfileToggleRow(
                            icon: "Don’t-disturb",
                            title: "Don’t disturb",
                            isOn: $dontDisturbEnabled
                        )

                        Text("Get notification while your day")
                            .font(.custom("DMSans-Regular", size: 14))
                            .foregroundColor(Color(hex: "6F6F6F"))
                            .padding(.leading, 6)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 46)

                    // MARK: - About Section
                    VStack(alignment: .leading, spacing: 18) {
                        Text("About")
                            .font(.custom("DMSans-SemiBold", size: 20))
                            .foregroundColor(Color(hex: "252525"))
                            .padding(.leading, 14)

                        ProfileAboutRow(
                            icon: "questionmark",
                            title: "Help& support"
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 34)

                    Button(action: {
                        print("Delete account tapped")
                    }) {
                        Text("Delete an account")
                            .font(.custom("DMSans-SemiBold", size: 16))
                            .foregroundColor(Color(hex: "6F6F6F"))
                            .underline()
                    }
                    .padding(.top, 60)
                    .padding(.bottom, 62)
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
                .font(.custom("DMSans-SemiBold", size: 22))
                .foregroundColor(Color("TitleColor"))

            TextField("Enter your name", text: $name)
                .font(.custom("DMSans-Regular", size: 16))
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
                        .font(.custom("DMSans-Regular", size: 16))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.black.opacity(0.06))
                        .clipShape(Capsule())
                }

                Button(action: onSave) {
                    Text("Save")
                        .font(.custom("DMSans-SemiBold", size: 16))
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
                .font(.custom("DMSans-Bold", size: 16))
                .foregroundColor(Color(hex: "252525"))

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
                    .foregroundColor(.black)
            }

            Text(title)
                .font(.custom("DMSans-Bold", size: 20))
                .foregroundColor(Color(hex: "252525"))

            Spacer()
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
