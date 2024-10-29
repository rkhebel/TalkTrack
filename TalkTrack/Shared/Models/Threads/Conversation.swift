//
//  Conversation.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 8/18/24.
//

import SwiftUI
import SwiftOpenAI
import SwiftData

@Model
class Conversation: Identifiable {
    var id: UUID = UUID()
    var createdAt: Date
    var openAIID: String
    var assistantID: String?
    var messages: [ChatMessage]

    init(createdAt: Date = Date(), messages: [ChatMessage], openAIID: String, assistantID: String?) {
        self.createdAt = createdAt
        self.messages = messages
        self.openAIID = openAIID
        self.assistantID = assistantID
    }

    // create a thread from scratch in openai as well
    convenience init?(openAIService: OpenAIService, messages: [MessageObject]?, assistantID: String) async {
        do {
            let parameters = CreateThreadParameters(messages: messages)
            let thread = try await openAIService.createThread(parameters: parameters)

            var chatMessages: [ChatMessage] = []
            for message in messages ?? [] {
                if let chatMessage = ChatMessage(from: message) {
                    chatMessages.append(chatMessage)
                }
            }

            // Create and return the Thread object
            self.init(messages: chatMessages, openAIID: thread.id, assistantID: assistantID)
        } catch APIError.responseUnsuccessful(let description, let statusCode) {
            print("Network error with status code: \(statusCode) and description: \(description)")
            return nil
        } catch {
            // Handle and log errors
            print("Failed to create thread: \(error)")
            return nil
        }
    }

    func addMessage(_ message: ChatMessage) {
        messages.append(message)
    }

    static func fetchAllMessages(threadID: String, using openAIService: OpenAIService) async throws -> [ChatMessage] {
        var allMessages = [ChatMessage]()
        var lastMessageID: String? = nil
        var retryCount = 0

        repeat {
            do {
                // Attempt to fetch messages from the API
                let response = try await openAIService.listMessages(threadID: threadID, limit: 100, order: "asc", after: lastMessageID, before: nil, runID: nil)

                // Convert the retrieved messages to ChatMessage objects and append to allMessages
                let messages = response.data.compactMap { ChatMessage(from: $0) }
                allMessages.append(contentsOf: messages)

                // Update lastMessageID for the next pagination call
                lastMessageID = response.data.last?.id

                // Reset retry count after a successful fetch
                retryCount = 0

            } catch {
                // Log and handle the error
                print("Failed to fetch messages: \(error)")

                // Retry up to 3 times before throwing the error
                if retryCount < 3 {
                    retryCount += 1
                } else {
                    throw error
                }
            }

        } while lastMessageID != nil // Continue fetching until there are no more messages to paginate through

        return allMessages
    }
}

extension Conversation {
    static func sampleConversation() -> Conversation {
        let conversation = Conversation(
            messages: [ChatMessage(role: .user, text: "Hello"), ChatMessage(role: .assistant, text: "How are you doing today?")],
            openAIID: "Test Conversation",
            assistantID: UserDefaults(suiteName: "group.com.TalkTrack.SharedData")?.string(forKey: "assistantID") ?? "defaultAssistant"
        )
        return conversation
    }
}
