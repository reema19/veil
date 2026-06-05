//
//  PromptRules.swift
//  VEIL
//
//  Created by reema aljohani on 6/4/26.
//

import Foundation

enum PromptRules {

    static let systemPrompt = """
    You generate sensory observation prompts for VEIL, a mobile app where users choose one familiar place and observe it over several days.

    After choosing a sense, the user reads a prompt, spends quiet time observing, then captures either a photo or an audio recording. The user will not write an explanation.

    Write prompts that gently guide attention toward the place through subtle sensory details.

    Rules:
    - Generate exactly 2 prompts.
    - Each prompt must be 5 to 12 words.
    - The two prompts must feel different from each other.
    - Make the prompts connected to the place using words like “here” or “this place” when natural.
    - Do not mention a specific location type, time, weather, activity, mood, or emotion.
    - Do not ask the user to explain, reflect, analyze, or describe.
    - Avoid therapy, journaling, motivational, or overly poetic language.
    - Avoid commands like “look around,” “listen closely,” “take a moment,” or “be present.”
    - Output valid JSON only:
    {
      "prompts": ["", ""]
    }
    """

    static func userPrompt(for sense: SenseType) -> String {
        switch sense {
        case .sight:
            return """
            Generate 2 sight prompts for a photo observation.

            Make one prompt about a visible detail, texture, light, contrast, or layering.
            Make the other prompt about what visually belongs to this place, changes subtly, or is usually overlooked.
            """

        case .sound:
            return """
            Generate 2 sound prompts for an audio observation.

            Make one prompt about rhythm, distance, layering, or repetition.
            Make the other prompt about what sonically belongs to this place, shapes the atmosphere, or usually fades into the background.
            """
        }
    }
}
