//
//  ChatMessageView.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 8/22/24.
//

import SwiftUI

struct ChatMessageView: View {
    var message: ChatMessage
    var body: some View {
        HStack {
            Text(message.message)
                .padding()
            Spacer()
        }
    }
}
