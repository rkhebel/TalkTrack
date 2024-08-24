//
//  Assistant.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 8/21/24.
//

import Foundation

struct Assistant: Identifiable, Codable {
    let id: String
    let object: String?
    var createdAt: Date
    var name: String?
    var description: String?
    var model: String
    var instructions: String?
    var tools: [Tool]?
    var toolResources: ToolResources?
    var metadata: [String: String]?
    var temperature: Double?
    var topP: Double?
    var responseFormat: ResponseFormat
    
    private func update(updates: [String: Any]) async throws -> Assistant {
        return try await OpenAIAPI.modifyAssistant(id: self.id, updates: updates)
    }
}

