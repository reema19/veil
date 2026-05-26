//
//  sightquestions.swift
//  VEIL
//
//  Created by Ghady Al Omar on 06/12/1447 AH.
//
import SwiftUI

struct sightquestions: View {
    
    let place: WatchingPlace
    
    var body: some View {
        PromptQuestionView(
            viewModel: PromptViewModel(
                sessionTitle: place.title,
                sessionSubtitle: "Day \(place.currentDay) of \(place.totalDays)",
                sectionTitle: "Stay with what you see",
                sectionSubtitle: "You don't need to capture everything.\nOne thing is enough.",
                prompts: [
                    SensePrompt(question: "What detail would you keep from here?", sense: .sight),
                    SensePrompt(question: "What would disappear if you blinked?", sense: .sight)
                ]
            )
        )
    }
}

// #Preview { sightquestions() }
