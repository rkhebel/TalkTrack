//
//  ChatHistory.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 8/18/24.
//

import Foundation
import SwiftOpenAI

@Observable
class ChatMessage: Identifiable, Codable {
    let id: String
    let createdAt: Date
    let role: MessageRole
    var text: String
    
    init(id: String, createdAt: Date, role: MessageRole, text: String) {
            self.id = id
            self.createdAt = createdAt
            self.role = role
            self.text = text
        }
        
    enum MessageRole: String, Codable, Hashable, CaseIterable {
        case user
        case assistant
    }
    
    // This is a convenience init, meaning that I can call self.init at the bottom to create a new messageobject.
    // Additionally it's a failable init (denoted by init?), which means it can return nil. 
    convenience init?(from messageObject: MessageObject) {
        var messageText = ""
        
        for content in messageObject.content {
            switch content {
            case .text(let textStruct):
                messageText += textStruct.text.value
            case .imageFile:
                messageText += "\n[This bot is only configured to output text. Non-text content cannot be displayed.]\n"
            }
        }
        
        guard !messageText.isEmpty else {
            return nil // Return nil if no content was successfully extracted
        }
        
        // Convert role from String to MessageRole enum
        let role: ChatMessage.MessageRole
        switch messageObject.role.lowercased() {
        case "user":
            role = .user
        case "assistant":
            role = .assistant
        default:
            return nil // Return nil if the role is not recognized
        }
        
        // Convert the timestamp from seconds to Date
        let date = Date(timeIntervalSince1970: TimeInterval(messageObject.createdAt))
        
        // Create and return a new ChatMessage
        self.init(id: messageObject.id, createdAt: date, role: role, text: messageText)
    }
    
}
