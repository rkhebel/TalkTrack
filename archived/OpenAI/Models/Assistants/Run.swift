//
//  Run.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 8/23/24.
//

import Foundation

struct Run: Codable {
    let id: String
    let object: String
    let createdAt: Date
    let threadId: String
    let assistantId: String
    let status: Status
    let requiredAction: RequiredAction?
    let lastError: RunError?
    let expiresAt: Date?
    let startedAt: Date?
    let cancelledAt: Date?
    let failedAt: Date?
    let completedAt: Date?
    let incompleteDetails: IncompleteDetails?
    let model: String
    let instructions: String
    let tools: [Tool]
    let metadata: [String: String]
    let usage: Usage?
    let temperature: Double?
    let topP: Double?
    let maxPromptTokens: Int?
    let maxCompletionTokens: Int?
    let truncationStrategy: TruncationStrategy
    let toolChoice: ToolChoice?
    let parallelToolCalls: Bool
    let responseFormat: ResponseFormat?
    

}

extension Run {
    enum Status: String, Codable {
        case queued = "queued"
        case in_progress = "in_progress"
        case requires_action = "requires_action"
        case cancelling = "cancelling"
        case cancelled = "cancelled"
        case failed = "failed"
        case completed = "completed"
        case incomplete = "incomplete"
        case expired = "expired"
    }
    
    // Nested structs for more complex fields
    struct RequiredAction: Codable {
        let type: RequiredActionType
        let submitToolOutputs: SubmitToolOutputs
        
        enum RequiredActionType: String, Codable {
            case submitToolOutputs = "submit_tool_outputs"
        }
        
        struct SubmitToolOutputs: Codable {
            let toolCalls: [ToolCall]
        }

        struct ToolCall: Codable {
            let id: String
            let type: String
            let function: Function?

            struct Function: Codable {
                let name: String
                let arguments: String
            }
        }
    }

    struct RunError: Codable {
        let code: RunErrorCode
        let message: String
        
        enum RunErrorCode: String, Codable {
            case serverError = "server_error"
            case rateLimitExceeded = "rate_limit_exceeded"
            case invalidPrompt = "invalid_prompt"
        }
    }

    struct IncompleteDetails: Codable {
        let reason: String
    }

    struct Usage: Codable {
        let completionTokens: Int
        let promptTokens: Int
        let totalTokens: Int
    }

    struct TruncationStrategy: Codable {
        let type: TruncationStrategyType
        let last_messages: Int?
        
        enum TruncationStrategyType: String, Codable {
            case auto = "auto"
            case lastMessages = "last_messages"
        }
    }

    struct ToolChoice: Codable {
        let type: ToolChoiceType
        let function: ToolChoiceFunction?
        
        enum ToolChoiceType: String, Codable {
            case none = "none"
            case auto = "auto"
            case required = "required"
        }
        
        struct ToolChoiceFunction: Codable {
            let name: String
        }
        
    }

}
