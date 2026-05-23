//
//  OnboardingView.swift
//  VEIL
//
//  Created by Ghady Al Omar on 06/12/1447 AH.
//

import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()

    var body: some View {
        NavigationStack {
            BePresentView(page: viewModel.pages[0])
        }
    }
}

// MARK: - Previews

#Preview {
    OnboardingView()
}

#Preview {
    BePresentView(page: OnboardingViewModel().pages[0])
}

#Preview {
    BePresentView2(page: OnboardingViewModel().pages[1])
}

#Preview {
    BePresentView3(page: OnboardingViewModel().pages[2])
}
