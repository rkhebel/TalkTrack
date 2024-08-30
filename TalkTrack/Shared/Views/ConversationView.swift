//
//  ConversationView.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 8/26/24.
//

import SwiftUI
import SwiftOpenAI
import Foundation

struct ConversationView: View {
    @State private var viewModel: ViewModel
    
    init(openAIService: OpenAIService, threadID: String, assistantID: String) {
        _viewModel = State(initialValue: ViewModel(openAIService: openAIService, threadID: threadID, assistantID: assistantID))
    }

    var body: some View {
        VStack {
            VStack {
                if let thread = viewModel.thread {
                    ScrollViewReader { proxy in
                        ScrollView {
                            ForEach(thread.messages, id: \.id) { message in
                                switch message.role {
                                case .user:
                                    UserChatBubble(message: message.text)
                                case .assistant:
                                    AssistantChatBubble(message: message.text)
                                }
                            }
                            Color.clear
                                .frame(height: 1)
                                .id("BOTTOM")
                        }
                        .scrollDismissesKeyboard(.interactively)
                        .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                        .onChange(of: thread.messages.count) {
                            print("message count change")
                            scrollToBottom(proxy)
                        }
                        .onChange(of: thread.messages.last?.text) {
                            print("last message changing")
                            scrollToBottom(proxy)
                        }
                        .onAppear {
                            print("on appear")
                            scrollToBottom(proxy)
                        }
                    }
                }
                else {
                    Text("Loading messages...")
                        .onAppear {
                            Task {
                                await viewModel.initializeThread()
                            }
                        }
                }
            }
            VStack {
                HStack {
                    TextField("Enter prompt", text: $viewModel.prompt)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.alphabet)
                        .disableAutocorrection(true)
                    Button(action: {
                        viewModel.isRecording.toggle()
                        if viewModel.isRecording {
                            viewModel.speechRecognizer.startTranscribing()
                        } else {
                            viewModel.prompt = viewModel.speechRecognizer.stopTranscribing()
                        }
                    }) {
                        Image(systemName: viewModel.isRecording ? "mic.circle.fill" : "mic.circle")
                            .imageScale(.large)
                    }
                    Button {
                        Task {
                            try await viewModel.submitMessage()
                        }
                    } label: {
                        Image(systemName: viewModel.prompt.isEmpty ? "arrow.up.circle" : "arrow.up.circle.fill")
                            .imageScale(.large)
                    }
                }
            }
            .background(Color(UIColor.systemBackground))
        }
        .onTapGesture {
            viewModel.dismissKeyboard()
        }
        .onAppear {
            viewModel.preloadSpeech()
        }
    }
    
    @MainActor
    private func scrollToBottom(_ scrollViewProxy: ScrollViewProxy) {
        print("scroll to bottom called")
        withAnimation {
            scrollViewProxy.scrollTo("BOTTOM", anchor: .bottom)
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
//        .padding(.trailing, 60) // Add padding to avoid edge alignment
        .padding(.vertical, 4) // Space between messages
    }
}

#Preview {
    ConversationView(openAIService: OpenAIServiceFactory.service(apiKey: OpenAIAPIConfig.apiKey),
                     threadID: UserDefaults(suiteName: "com.ryanhebel.TalkTrack.SharedData")?.string(forKey: "threadID") ?? "",
                     assistantID: UserDefaults(suiteName: "com.ryanhebel.TalkTrack.SharedData")?.string(forKey: "assistantID") ?? "")
}
