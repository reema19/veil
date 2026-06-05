//
//  PromptViewModel.swift
//  VEIL
//

import Foundation
import Combine

@MainActor
final class PromptViewModel: ObservableObject {

    @Published var currentPromptIndex: Int = 0
    @Published var sessionTitle: String
    @Published var sessionSubtitle: String
    @Published var sectionTitle: String
    @Published var sectionSubtitle: String
    @Published var prompts: [SensePrompt] = []
    @Published var isLoadingPrompts: Bool = true

    private let fallbackPrompts: [SensePrompt]
    private var didLoadAIPrompts = false

    var currentPrompt: SensePrompt {
        if prompts.indices.contains(currentPromptIndex) {
            return prompts[currentPromptIndex]
        }

        return fallbackPrompts.first ?? SensePrompt(
            question: "What detail feels easy to notice here?",
            sense: .sight
        )
    }

    var totalPrompts: Int {
        isLoadingPrompts ? 2 : max(prompts.count, 2)
    }

    var promptLabel: String {
        isLoadingPrompts
        ? "Preparing prompts"
        : "Prompt \(currentPromptIndex + 1) of \(totalPrompts)"
    }

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
        self.fallbackPrompts = prompts

        Task {
            await loadAIPromptsIfNeeded()
        }
    }

    func loadAIPromptsIfNeeded() async {
        guard !didLoadAIPrompts else { return }
        didLoadAIPrompts = true

        guard let sense = fallbackPrompts.first?.sense else {
            showFallbackPrompts()
            return
        }

        await withTaskGroup(of: [String]?.self) { group in

            group.addTask {
                do {
                    return try await OpenAIService.shared.generatePrompts(for: sense)
                } catch {
                    print("Failed to generate AI prompts:", error.localizedDescription)
                    return nil
                }
            }

            group.addTask {
                try? await Task.sleep(nanoseconds: 5_000_000_000)
                return nil
            }

            guard let firstResult = await group.next() else {
                showFallbackPrompts()
                group.cancelAll()
                return
            }

            group.cancelAll()

            guard let generatedQuestions = firstResult else {
                showFallbackPrompts()
                return
            }

            let cleanQuestions = generatedQuestions
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }

            guard cleanQuestions.count == 2 else {
                showFallbackPrompts()
                return
            }

            prompts = cleanQuestions.map {
                SensePrompt(question: $0, sense: sense)
            }

            currentPromptIndex = 0
            isLoadingPrompts = false
        }
    }

    private func showFallbackPrompts() {
        prompts = fallbackPrompts
        currentPromptIndex = 0
        isLoadingPrompts = false
    }

    func tryAnother() {
        guard !isLoadingPrompts else { return }
        guard prompts.count > 1 else { return }

        var nextIndex = Int.random(in: 0..<prompts.count)

        while nextIndex == currentPromptIndex {
            nextIndex = Int.random(in: 0..<prompts.count)
        }

        currentPromptIndex = nextIndex
    }

    func stayWithThis() {
        // PromptQuestionView handles the transition into observation mode.
    }
}
