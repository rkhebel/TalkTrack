//
//  CurrentWorkoutView.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 8/18/24.
//

import SwiftUI

struct CurrentWorkoutView: View {
    @State private var isRecording = false
    
    var body: some View {
        VStack {
            Text("Chat history")
                .font(.title)
            ScrollView {
                ForEach(Conversation.shared.chatHistory) { message in
                    ChatMessageView(message: message)
                }
            }
            .padding()
            Circle()
                .strokeBorder(lineWidth: 24)
                .overlay {
                    VStack {
                        Button(action: {
                            isRecording.toggle()
                            if isRecording {
                                Conversation.shared.startRecording()
                            } else {
                                let transcript = Conversation.shared.stopRecording()
                                Conversation.shared.updateHistory(transcript: transcript)
                            }
                        }) {
                            Text(isRecording ? "Stop" : "Record")
                                .padding()
                                .background(isRecording ? Color.gray : Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        Image(systemName: isRecording ? "mic" : "mic.slash")
                            .imageScale(.large)
                            .font(.title)
                            .padding()
                    }
                }
        }
        .padding()
    }
}

#Preview {
    CurrentWorkoutView()
}
