//
//  Mainpage.swift
//  VEIL
//
//  Created by Ghady Al Omar on 06/12/1447 AH.
//

import SwiftUI

struct Mainpage: View {

    // Keep old ViewModel name
    @StateObject private var vm = MainpageViewModel()

    // Keep navigation state, but navigation code is commented until MapScreen is added
    @State private var goToMapScreen = false

    // TODO: Uncomment this after you add LocationPermissionViewModel.swift
    // @StateObject private var locationPermissionViewModel = LocationPermissionViewModel()

    var body: some View {

        ZStack {

            Color("BackgroundColor")
                .ignoresSafeArea()

            VStack(spacing: 0) {

                // MARK: - Header
                HStack(alignment: .center) {

                    VStack(alignment: .leading, spacing: 4) {

                        Text("Good morning,")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(Color("SubtitleColor"))

                        Text("Ghady")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(Color("TitleColor"))
                    }

                    Spacer()
                }
                .padding(.horizontal, 38)
                .padding(.top, 20)
                .padding(.bottom, -8)

                Spacer()

                // MARK: - Empty State
                EmptyStateView(pulseAnimation: vm.pulseAnimation)

                Spacer()

                // MARK: - Add Place Button
                Button(action: {

                    // TODO: Later, when LocationPermissionViewModel is added,
                    // replace the temporary sheet opening below with this logic:

                    /*
                    locationPermissionViewModel.checkCurrentPermission()

                    if locationPermissionViewModel.permissionGranted {
                        goToMapScreen = true
                    } else {
                        withAnimation(.spring(response: 0.35,
                                              dampingFraction: 0.85)) {
                            vm.showLocationSheet = true
                        }
                    }
                    */

                    // Temporary behavior so the design works now:
                    withAnimation(.spring(response: 0.35,
                                          dampingFraction: 0.85)) {
                        vm.showLocationSheet = true
                    }

                }) {

                    Text("Add a place")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: 318)
                        .frame(height: 52)
                        .background(Color.black)
                        .cornerRadius(25)
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 24)
            }

            // MARK: - Sheet Overlay
            if vm.showLocationSheet {
                LocationPermissionSheetView(
                    onClose: {
                        withAnimation(.spring(response: 0.35,
                                              dampingFraction: 0.85)) {
                            vm.showLocationSheet = false
                        }
                    },
                    onDone: {
                        withAnimation(.spring(response: 0.35,
                                              dampingFraction: 0.85)) {
                            vm.showLocationSheet = false
                        }

                        // TODO: Later, when LocationPermissionViewModel is added,
                        // uncomment this to request location permission after closing the sheet.

                        /*
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            locationPermissionViewModel.requestPermission()
                        }
                        */
                    }
                )
            }
        }
        .onAppear {
            vm.startPulse()
        }

        // MARK: - Navigation to MapScreen
        // TODO: Uncomment this after you add MapScreen.swift

        /*
        .navigationDestination(isPresented: $goToMapScreen) {
            MapScreen()
        }
        */

        // MARK: - Listen for Permission Changes
        // TODO: Uncomment this after you add LocationPermissionViewModel.swift

        /*
        .onChange(of: locationPermissionViewModel.permissionGranted) { oldValue, newValue in
            if newValue {
                goToMapScreen = true
            }
        }
        */
    }
}

#Preview {
    NavigationStack {
        Mainpage()
    }
}
