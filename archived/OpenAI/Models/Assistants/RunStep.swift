//
//  RunStep.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 8/23/24.
//

import Foundation

struct RunStep: Codable {
    let id: String
    let object: String
    let createdAt: Date
    let assistantId: String
    let threadId: String
    let runId: String
    let type: RunStepType
    let status: RunStepStatus
    let stepDetails: StepDetails
    let lastError: Run.RunError?
    let expiredAt: Date?
    let cancelledAt: Date?
    let failedAt: Date?
    let completedAt: Date?
    let metadata: [String: String]
    let usage: Usage?
}

extension RunStep {
    enum RunStepType: String, Codable {
        case messageCreation = "message_creation"
        case toolCalls = "tool_calls"
    }

    enum RunStepStatus: String, Codable {
        case inProgress = "in_progress"
        case cancelled = "cancelled"
        case failed = "failed"
        case completed = "completed"
        case expired = "expired"
    }

    struct StepDetails: Codable {
        let messageCreation: MessageCreation?
        let toolCalls: [ToolCall]?

        struct MessageCreation: Codable {
            let messageId: String
        }

        struct ToolCall: Codable {
            let id: String
            let type: ToolCallType
            let codeInterpreter: CodeInterpreter?
            let fileSearch: [String: String]?
            let function: Function?

            enum ToolCallType: String, Codable {
                case codeInterpreter = "code_interpreter"
                case fileSearch = "file_search"
                case function = "function"
            }

            struct CodeInterpreter: Codable {
                let input: String
                let outputs: [Output]

                struct Output: Codable {
                    let type: OutputType
                    let logs: String?
                    let image: Image?

                    enum OutputType: String, Codable {
                        case logs
                        case image
                    }

                    struct Image: Codable {
                        let fileId: String
                    }
                }
            }

            struct Function: Codable {
                let name: String
                let arguments: String
                let output: String?
            }
        }
    }

    struct Usage: Codable {
        let completionTokens: Int
        let promptTokens: Int
        let totalTokens: Int
    }
}
