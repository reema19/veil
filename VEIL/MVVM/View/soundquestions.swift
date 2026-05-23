//
//  soundquestions.swift
//  VEIL
//
//  Created by Ghady Al Omar on 06/12/1447 AH.
//

import SwiftUI

struct soundquestions: View {
    
    @StateObject private var viewModel = PromptViewModel(
        sectionTitle: "Stay with what you hear",
        sectionSubtitle: "One layer of the place is enough",
        prompts: [
            SensePrompt(question: "What sound would you keep from here?", sense: .sound),
            SensePrompt(question: "What sound fades the moment you notice it?", sense: .sound)
        ]
    )
    
    var body: some View {
        PromptQuestionView(viewModel: viewModel)
    }
}

#Preview { soundquestions() }
