//
//  ChatHistory.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 8/18/24.
//

import Foundation

class ChatMessage: Identifiable {
    
    enum Role: Codable, Hashable, CaseIterable {
        case user
        case assistant
    }
    
    var id: UUID = UUID()
    var date: Date
    var message: String
    var role: Role
    
    init(date: Date, message: String, role: Role) {
        self.date = date
        self.message = message
        self.role = role
    }
    
}
