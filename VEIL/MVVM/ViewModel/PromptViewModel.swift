//
//  PromptViewModel.swift
//  VEIL
//
//  Created by Ghady Al Omar on 06/12/1447 AH.
//
import Foundation
import Combine

class PromptViewModel: ObservableObject {
    
    // MARK: - Published
    @Published var currentPromptIndex: Int = 0
    @Published var sessionTitle: String
    @Published var sessionSubtitle: String
    @Published var sectionTitle: String
    @Published var sectionSubtitle: String

    // MARK: - Private
    private let prompts: [SensePrompt]

    // MARK: - Computed
    var currentPrompt: SensePrompt {
        prompts[currentPromptIndex]
    }

    var totalPrompts: Int {
        prompts.count
    }

    var promptLabel: String {
        "Prompt \(currentPromptIndex + 1) of \(totalPrompts)"
    }

    // MARK: - Init
    init(
        sessionTitle: String = "Morning café",
        sessionSubtitle: String = "Day 4 of observation",
        sectionTitle: String,
        sectionSubtitle: String,
        prompts: [SensePrompt]
    ) {
        self.sessionTitle = sessionTitle
        self.sessionSubtitle = sessionSubtitle
        self.sectionTitle = sectionTitle
        self.sectionSubtitle = sectionSubtitle
        self.prompts = prompts
    }

    // MARK: - Actions
    func tryAnother() {
        guard prompts.count > 1 else { return }
        var next = Int.random(in: 0..<prompts.count)
        while next == currentPromptIndex { next = Int.random(in: 0..<prompts.count) }
        currentPromptIndex = next
    }

    func stayWithThis() {
        // Navigation logic — يكمّل للـ view التالي
    }
}
