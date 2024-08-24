//
//  Conversation.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 8/18/24.
//

import SwiftUI

@Observable
class Conversation {
    static let shared = Conversation()
    
    private var speechRecognizer = SpeechRecognizer()
    private var transcript: String = ""
    var chatHistory: [ChatMessage] = []
    
    @MainActor
    func startRecording() {
        speechRecognizer.resetTranscript()
        speechRecognizer.startTranscribing()
    }
    
    @MainActor
    func stopRecording() -> String {
        transcript = speechRecognizer.transcript
        speechRecognizer.stopTranscribing()
        return transcript
    }
    
    func updateHistory(transcript: String) {
        chatHistory.append(ChatMessage(date: Date(), message: transcript, role: .user))
    }
}
