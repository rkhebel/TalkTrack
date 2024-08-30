//
//  Conversation.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 8/18/24.
//

import SwiftUI
import SwiftOpenAI

@Observable
class Thread: Identifiable, Codable {
    let id: String
    let createdAt: Date
    var messages: [ChatMessage]
    
    init(id: String, createdAt: Date, messages: [ChatMessage]) {
        self.id = id
        self.createdAt = createdAt
        self.messages = messages
    }
    
    
    func addMessage(_ message: ChatMessage) {
        messages.append(message)
    }
    
    convenience init?(threadID: String, openAIService: OpenAIService) async {
        do {
            // Retrieve thread details
            let threadDetails = try await openAIService.retrieveThread(id: threadID)
            
            // Convert the thread creation timestamp to a Date object
            let createdAtDate = Date(timeIntervalSince1970: TimeInterval(threadDetails.createdAt))
            
            // List all messages in the thread
            let chatMessages = try await Thread.fetchAllMessages(threadID: threadID, using: openAIService)
            
            // Create and return the Thread object
            self.init(id: threadID, createdAt: createdAtDate, messages: chatMessages)
            
        } catch {
            // Handle and log errors
            print("Failed to create thread with ID \(threadID): \(error)")
            return nil
        }
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
