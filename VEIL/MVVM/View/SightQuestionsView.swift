//
//  SightQuestionsView.swift
//  VEIL
//
import SwiftUI

struct SightQuestionsView: View {

    let place: Place
    @StateObject private var viewModel: PromptViewModel

    init(place: Place) {
        self.place = place
        _viewModel = StateObject(
            wrappedValue: PromptViewModel(
                sessionTitle: place.name,
                sessionSubtitle: "Day \(place.currentDay) of \(place.activeDays)",
                sectionTitle: "Stay with what you see",
                sectionSubtitle: "You don't need to capture everything.\nOne thing is enough.",
                prompts: [
                    SensePrompt(question: "What detail would you keep from here?", sense: .sight),
                    SensePrompt(question: "What would disappear if you blinked?", sense: .sight)
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
