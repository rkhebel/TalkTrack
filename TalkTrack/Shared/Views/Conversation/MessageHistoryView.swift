//
//  MessageHistoryView.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 9/13/24.
//

import SwiftUI

struct MessageHistoryView: View {
    @State var conversation: Conversation
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    ForEach(conversation.messages, id: \.id) { message in
                        ChatBubbleView(message: message)
                    }
                    Color.clear
                        .frame(height: 1)
                        .id("BOTTOM")
                }
                .scrollDismissesKeyboard(.interactively)
                .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                .onChange(of: conversation.messages.count) {
                    scrollToBottom(proxy)
                }
                .onChange(of: conversation.messages.last?.text) {
                    scrollToBottom(proxy)
                }
                .onAppear {
                    scrollToBottom(proxy)
                }
            }
        }
    }
    
    @MainActor
    private func scrollToBottom(_ scrollViewProxy: ScrollViewProxy) {
        withAnimation {
            scrollViewProxy.scrollTo("BOTTOM", anchor: .bottom)
        }
    }
}
