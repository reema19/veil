//
//  OpenAIService.swift
//  VEIL
//
//  Created by reema aljohani on 6/4/26.
//
import Foundation

final class OpenAIService {

    static let shared = OpenAIService()
    private init() {}

    func generatePrompts(for sense: SenseType) async throws -> [String] {
        let requestBody = OpenAIRequestBody(
            model: "gpt-4.1-mini",
            input: [
                OpenAIInputMessage(
                    role: "system",
                    content: PromptRules.systemPrompt
                ),
                OpenAIInputMessage(
                    role: "user",
                    content: PromptRules.userPrompt(for: sense)
                )
            ],
            text: OpenAITextFormat(
                format: OpenAIJSONSchemaFormat(
                    type: "json_schema",
                    name: "veil_prompts",
                    strict: true,
                    schema: PromptJSONSchema.schema
                )
            )
        )

        guard let url = URL(string: "https://api.openai.com/v1/responses") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(Secrets.openAIAPIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            let message = String(data: data, encoding: .utf8) ?? "Unknown OpenAI error"
            throw NSError(
                domain: "OpenAIService",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: message]
            )
        }

        let decoded = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        let jsonText = decoded.outputText

        guard let jsonData = jsonText.data(using: .utf8) else {
            throw NSError(
                domain: "OpenAIService",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "Could not convert output text to data."]
            )
        }

        let promptResponse = try JSONDecoder().decode(PromptResponse.self, from: jsonData)
        return promptResponse.prompts
    }
}

// MARK: - Request Models

private struct OpenAIRequestBody: Encodable {
    let model: String
    let input: [OpenAIInputMessage]
    let text: OpenAITextFormat
}

private struct OpenAIInputMessage: Encodable {
    let role: String
    let content: String
}

private struct OpenAITextFormat: Encodable {
    let format: OpenAIJSONSchemaFormat
}

private struct OpenAIJSONSchemaFormat: Encodable {
    let type: String
    let name: String
    let strict: Bool
    let schema: [String: JSONValue]
}

// MARK: - Response Models

private struct OpenAIResponse: Decodable {
    let output: [OpenAIOutputItem]

    var outputText: String {
        output
            .flatMap { $0.content ?? [] }
            .compactMap { $0.text }
            .joined()
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

private struct OpenAIOutputItem: Decodable {
    let content: [OpenAIOutputContent]?
}

private struct OpenAIOutputContent: Decodable {
    let text: String?
}

// MARK: - JSON Schema

private enum PromptJSONSchema {
    static let schema: [String: JSONValue] = [
        "type": .string("object"),
        "additionalProperties": .bool(false),
        "properties": .object([
            "prompts": .object([
                "type": .string("array"),
                "minItems": .number(2),
                "maxItems": .number(2),
                "items": .object([
                    "type": .string("string")
                ])
            ])
        ]),
        "required": .array([
            .string("prompts")
        ])
    ]
}

// MARK: - Flexible JSON Encoding

private enum JSONValue: Encodable {
    case string(String)
    case number(Int)
    case bool(Bool)
    case array([JSONValue])
    case object([String: JSONValue])

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .string(let value):
            try container.encode(value)
        case .number(let value):
            try container.encode(value)
        case .bool(let value):
            try container.encode(value)
        case .array(let value):
            try container.encode(value)
        case .object(let value):
            try container.encode(value)
        }
    }
}
