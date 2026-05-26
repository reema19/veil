//
//  sightquestions.swift
//  VEIL
//
//  Created by Ghady Al Omar on 06/12/1447 AH.
//
import SwiftUI

struct sightquestions: View {
    
    @StateObject private var viewModel = PromptViewModel(
        sectionTitle: "Stay with what you see",
        sectionSubtitle: "You don't need to capture everything.\none thing is enough.",
        prompts: [
            SensePrompt(question: "What sound belongs to this place?", sense: .sight),
            SensePrompt(question: "What detail would disappear if you blinked?", sense: .sight)
        ]
    )
    
    var body: some View {
        PromptQuestionView(viewModel: viewModel)
    }
}

#Preview { sightquestions() }
