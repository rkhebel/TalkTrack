//
//  ChatBubbleView.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 9/13/24.
//

import SwiftUI

struct ChatBubbleView: View {
    let message: ChatMessage
    
    var body: some View {
        switch message.role {
        case .user:
            UserChatBubble(message: message.text)
        case .assistant:
            AssistantChatBubble(message: message.text)
        }
    }
}

struct UserChatBubble: View {
    let message: String
    
    var body: some View {
        HStack {
            Spacer() // Push the bubble to the right
            
            Text(message)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(16)
                .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .trailing)
        }
        .padding(.leading, 60) // Add padding to avoid edge alignment
        .padding(.vertical, 4) // Space between messages
    }
}

struct AssistantChatBubble: View {
    let message: String
    
    var body: some View {
        HStack {
            Text(message)
                .padding()
                .background(Color.gray)
                .foregroundColor(.black)
                .cornerRadius(16)
                .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .leading)
            
            Spacer() // Push the bubble to the left
        }
        .padding(.vertical, 4) // Space between messages
    }
}
