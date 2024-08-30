//
//  ConversationViewModel.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 8/29/24.
//

import SwiftUI
import SwiftOpenAI
import Foundation

extension ConversationView {
    @Observable
    class ViewModel {
        private let openAIService: OpenAIService
        var isRecording = false
        var prompt: String = ""
        private var threadID: String
        private var assistantID: String
        var speechRecognizer = SpeechRecognizer.shared
        var thread: Thread?
        
        init(openAIService: OpenAIService, threadID: String, assistantID: String) {
            self.openAIService = openAIService
            self.threadID = threadID
            self.assistantID = assistantID
        }
        
        func initializeThread() async {
            self.thread = await Thread(threadID: threadID, openAIService: openAIService)
            await reload()
        }
        
        // purpose of this function is to set up an audio engine once so that it's faster on subsequent calls
        @MainActor
        func preloadSpeech() {
            speechRecognizer.startTranscribing()
            speechRecognizer.resetTranscript()
        }
        
        func reload() async {
            guard let newThread = await Thread(threadID: threadID, openAIService: openAIService) else {
                print("Thread not initialized")
                return
            }
            self.thread = newThread
        }

        func submitMessage() async throws {
            let newMessage = try await openAIService.createMessage(threadID: threadID, parameters: .init(role: .user, content: prompt))
            
            if let chatMessage = ChatMessage(from: newMessage) {
                thread?.addMessage(chatMessage)
            }
            
            prompt = ""
            
            let logWorkoutTool = createLogWorkoutFunction()
            let runParameters = RunParameter(assistantID: assistantID, tools: [logWorkoutTool])
            var toolOutputs: [RunToolsOutputParameter.ToolOutput] = []
            let stream = try await openAIService.createRunStream(threadID: threadID, parameters: runParameters)
            for try await result in stream {
                try await handleStreamedEvent(result: result, toolOutputs: &toolOutputs)
            }
        }
        
        private func handleStreamedEvent(result: AssistantStreamEvent, toolOutputs: inout [RunToolsOutputParameter.ToolOutput]) async throws {
            switch result {
            case .threadMessageDelta(let messageDelta):
                guard let thread = thread else { return }
                                
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
                if let existingMessage = thread.messages.first(where: { $0.id == messageDelta.id }) {
                    existingMessage.text += newMessageText
                } else {
                    let newMessage = ChatMessage(id: messageDelta.id, createdAt: Date(), role: ChatMessage.MessageRole.assistant, text: newMessageText)
                    thread.addMessage(newMessage)
                }
                self.thread = thread
            case .threadRunStepDelta(let runStepDelta):
                for toolCall in runStepDelta.delta.stepDetails.toolCalls ?? [] {
                    switch toolCall.toolCall {
                    case .codeInterpreterToolCall(let RunStepToolCall):
                        print("PROVIDER: Code interpreter tool call \(RunStepToolCall)")
                    case .fileSearchToolCall(let RunStepToolCall):
                        print("PROVIDER: File search tool call \(RunStepToolCall)")
                    case .functionToolCall(let RunStepToolCall):
                        let output = logWorkout()
                        toolOutputs.append(RunToolsOutputParameter.ToolOutput(toolCallId: toolCall.id, output: output))
                    }
                }
            case .threadRunRequiresAction(let runObject):
                // If run requires action, submit tool outputs
                if runObject.requiredAction?.type == "submit_tool_outputs", !toolOutputs.isEmpty {
                    let outputParameters = RunToolsOutputParameter(toolOutputs: toolOutputs)
                    let outputStream = try await openAIService.submitToolOutputsToRunStream(
                        threadID: threadID,
                        runID: runObject.id,
                        parameters: outputParameters
                    )
                    
//                    // Handle the streaming events from the tool output submission
//                    for try await outputResult in outputStream {
//                        // Process the output submission events
//                        // Similar to how we process the events above
//                    }
                }
            case .threadRunCompleted(let runObject):
                // Run has completed, clear any temporary text
                print("Run Completed: \(runObject.id)")
            default:
                break
            }
        }
        
        func createLogWorkoutFunction() -> AssistantObject.Tool {
            let function = AssistantObject.Tool(
                type: .function,
                function: .init(
                    name: "logWorkout",
                    strict: false,
                    description: "Logs a workout session based on the user's input. Call this function when the user provides details about their exercise. If any required details are missing, prompt the user to fill in the gaps.",
                    parameters: .init(
                        type: .object,
                        properties: [
                            "exercise_name": .init(type: .string, description: "The name of the exercise performed, such as 'bench press' or 'squats'."),
                            "sets": .init(type: .integer, description: "The number of sets completed for the exercise."),
                            "reps": .init(type: .integer, description: "The number of repetitions completed in each set."),
                            "weight": .init(type: .number, description: "The weight used for the exercise, measured in pounds or kilograms.")
                        ],
                        required: ["exercise_name", "sets", "reps", "weight"]
                    )
                )
            )
            return function
        }
        
        func logWorkout() -> String {
            return "true"
        }
        
        func dismissKeyboard() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

