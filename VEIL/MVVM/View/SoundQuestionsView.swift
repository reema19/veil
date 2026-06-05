//
//  SoundQuestionsView.swift
//  VEIL
//

import SwiftUI

struct SoundQuestionsView: View {

    let place: Place
    @StateObject private var viewModel: PromptViewModel

    init(place: Place) {
        self.place = place
        _viewModel = StateObject(
            wrappedValue: PromptViewModel(
                sessionTitle: place.name,
                sessionSubtitle: "Day \(place.currentDay) of \(place.activeDays)",
                sectionTitle: "Stay with what you hear",
                sectionSubtitle: "One layer of the place is enough.",
                prompts: [
                    SensePrompt(question: "What sound would you keep from here?", sense: .sound),
                    SensePrompt(question: "What sound fades the moment you notice it?", sense: .sound)
                ]
            )
        )
    }

    var body: some View {
        PromptQuestionView(
            place: place,
            viewModel: viewModel
        )
    }
}
