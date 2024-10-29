//
//  ConversationView.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 8/26/24.
//

import SwiftUI
import SwiftOpenAI
import Foundation
import SwiftData

struct ConversationView: View {
    @Environment(\.dismiss) var dismiss
    @State var conversation: Conversation
    @State private var isRecording = false
    @State private var prompt: String = ""
    let dataHandler: DataHandler = DataProvider.shared.dataHandler()

    let openAIService: OpenAIService
    private let speechRecognizer = SpeechRecognizer.shared
    private var conversationService: ConversationService
    
    init(conversation: Conversation, openAIService: OpenAIService) {
        self._conversation = State(initialValue: conversation)
        self.openAIService = openAIService
        
        self.conversationService = ConversationService(
            conversation: conversation,
            openAIService: openAIService
        )
    }

    var body: some View {
        VStack {
            MessageHistoryView(conversation: conversation)
            .padding(.top, 10)
            VStack {
                HStack {
                    TextField("Enter prompt", text: $prompt)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.alphabet)
                        .disableAutocorrection(true)
                    Button(action: {
                        isRecording.toggle()
                        if isRecording {
                            speechRecognizer.startTranscribing()
                        } else {
                            prompt = speechRecognizer.stopTranscribing()
                        }
                    }) {
                        Image(systemName: isRecording ? "mic.circle.fill" : "mic.circle")
                            .imageScale(.large)
                    }
                    Button {
                        sendMessage()
                    } label: {
                        Image(systemName: prompt.isEmpty ? "arrow.up.circle" : "arrow.up.circle.fill")
                            .imageScale(.large)
                    }
                }
                .padding(.leading, 10)
                .padding(.trailing, 10)
            }
            .background(Color(UIColor.systemBackground))
        }
        .onTapGesture {
            dismissKeyboard()
        }
    }
    
    func sendMessage() {
        Task {
            let currentPrompt = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !currentPrompt.isEmpty else { return }
            prompt = ""
            do {
                try await conversationService.submitMessage(prompt: currentPrompt)
            } catch {
                print("Error submitting message: \(error.localizedDescription)")
                // Optionally, restore the previous prompt value
                prompt = currentPrompt
            }
        }
    }
    
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    return ConversationView(conversation: Conversation.sampleConversation(), openAIService: OpenAIServiceFactory.service(apiKey: OpenAIAPIConfig.apiKey))
        .modelContainer(DataProvider.shared.previewContainer())
}
