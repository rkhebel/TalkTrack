//
//  ConversationService.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 9/13/24.
//

import Foundation
import SwiftUI
import SwiftOpenAI
import SwiftData

class ConversationService {
    private let openAIService: OpenAIService
    private let conversation: Conversation
    
    init(conversation: Conversation, openAIService: OpenAIService) {
        self.conversation = conversation
        self.openAIService = openAIService
    }
    
    func submitMessage(prompt: String) async throws {
        try await createAndAddUserMessage(prompt: prompt)
        try await startRunStream()
    }
    
    private func createAndAddUserMessage(prompt: String) async throws {
        let newMessage = try await openAIService.createMessage(
            threadID: conversation.openAIID,
            parameters: .init(role: .user, content: prompt)
        )
        
        if let chatMessage = ChatMessage(from: newMessage) {
            await MainActor.run {
                conversation.addMessage(chatMessage)
            }
        }
    }
    
    private func startRunStream() async throws {
        guard let assistantID = conversation.assistantID else { return }
        let runParameters = RunParameter(assistantID: assistantID)
        var toolOutputs: [RunToolsOutputParameter.ToolOutput] = []
        
        let stream = try await openAIService.createRunStream(threadID: conversation.openAIID, parameters: runParameters)
        
        for try await result in stream {
            try await handleStreamedEvent(result: result, toolOutputs: &toolOutputs)
        }
    }
    
    private func handleStreamedEvent(result: AssistantStreamEvent, toolOutputs: inout [RunToolsOutputParameter.ToolOutput]) async throws {
        switch result {
        case .threadMessageDelta(let messageDelta):
            await handleThreadMessageDelta(messageDelta: messageDelta)
        case .threadRunRequiresAction(let runObject):
            try await handleThreadRunRequiresAction(runObject: runObject, toolOutputs: &toolOutputs)
        case .threadRunCompleted(let runObject):
            print("Run Completed: \(runObject.id)")
        default:
            break
        }
    }
    
    @MainActor
    private func handleThreadMessageDelta(messageDelta: MessageDeltaObject) {
        // Extract or create message text
        let newMessageText = messageDelta.delta.content.reduce(into: "") { result, content in
            switch content {
            case .text(let textContent):
                result += textContent.text.value
            case .imageFile:
                result += "\n[This bot is only configured to output text. Non-text content cannot be displayed.]\n"
            }
        }
        
        // Find or create the message
        if let existingMessage = conversation.messages.first(where: { $0.openAIID == messageDelta.id }) {
            existingMessage.text += newMessageText
        } else {
            let newMessage = ChatMessage(createdAt: Date(), openAIID: messageDelta.id, role: .assistant, text: newMessageText)
            conversation.addMessage(newMessage)
        }
    }
    
    private func handleThreadRunRequiresAction(runObject: RunObject, toolOutputs: inout [RunToolsOutputParameter.ToolOutput]) async throws {
        if runObject.requiredAction?.type == "submit_tool_outputs" {
            guard let toolCalls = runObject.requiredAction?.submitToolsOutputs.toolCalls else {
                print("No tool calls to submit.")
                return
            }
            
            for toolCall in toolCalls {
                let arguments = toolCall.function.arguments
                if let functionName = toolCall.function.name {
                    guard let data = arguments.data(using: .utf8) else {
                        print("Failed to parse arguments from function call.")
                        return
                    }
                    switch functionName {
                    case "logWorkout":
                        let output = "true"
                        toolOutputs.append(RunToolsOutputParameter.ToolOutput(toolCallId: toolCall.id ?? "", output: output))
                    default:
                        print("Unknown function called.")
                    }
                }
            }
            
            if !toolOutputs.isEmpty {
                let outputParameters = RunToolsOutputParameter(toolOutputs: toolOutputs)
                let outputStream = try await openAIService.submitToolOutputsToRunStream(
                    threadID: conversation.openAIID,
                    runID: runObject.id,
                    parameters: outputParameters
                )
                
                for try await outputResult in outputStream {
                    toolOutputs = []
                    try await handleStreamedEvent(result: outputResult, toolOutputs: &toolOutputs)
                }
            }
        }
    }
    
    private func logWorkout(data: Data) async throws -> String {
        do {
            // Parse the data into AssistantWorkout
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            guard let jsonDict = jsonObject as? [String: Any],
                  let payloadDict = jsonDict["payload"] as? [String: Any] else {
                return "failure"
            }
    
            let payloadData = try JSONSerialization.data(withJSONObject: payloadDict, options: [])
            let assistantWorkout = try JSONDecoder().decode(AssistantWorkout.self, from: payloadData)
    
            // Update the workout using DataHandler
//            try await dataHandler.updateWorkoutFromAssistant(workoutID: currentWorkout.id, assistantWorkout: assistantWorkout)
    
        } catch {
            print("Error when handling assistant data: \(error)")
            return "failure"
        }
    
        return "success"
    }
}
