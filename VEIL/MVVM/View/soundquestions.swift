//
//  soundquestions.swift
//  VEIL
//
//  Created by Ghady Al Omar on 06/12/1447 AH.
//

import SwiftUI

struct soundquestions: View {
    
    let place: WatchingPlace
    
    var body: some View {
        PromptQuestionView(
            viewModel: PromptViewModel(
                sessionTitle: place.title,
                sessionSubtitle: "Day \(place.currentDay) of \(place.totalDays)",
                sectionTitle: "Stay with what you hear",
                sectionSubtitle: "One layer of the place is enough.",
                prompts: [
                    SensePrompt(question: "What sound would you keep from here?", sense: .sound),
                    SensePrompt(question: "What sound fades the moment you notice it?", sense: .sound)
                ]
            )
        )
    }
}
// #Preview { soundquestions() }
