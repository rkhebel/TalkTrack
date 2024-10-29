//
//  ChatPageView.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 10/5/24.
//

import SwiftUI

struct ChatPageView: View {
    @Environment(\.openAIService) var openAIService

    var body: some View {
        Text("Chat Page")
        ConversationView(conversation: Conversation.sampleConversation(), openAIService: openAIService)
    }
}

#Preview {
    ChatPageView()
}
