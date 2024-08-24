//
//  ChatMessageView.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 8/18/24.
//

import SwiftUI

struct AssistantTestView: View {
//    var message: ChatMessage
    @State private var assistants: [Assistant] = []
    @State private var errorMessage: String?
    
    var body: some View {
        VStack {
            if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
            } else if assistants.isEmpty {
                Text("Loading assistants...")
            } else {
                List {
                    ForEach(assistants) { assistant in
                        Text(assistant.name ?? "No name")
                    }
                }
            }
            Spacer()
            HStack {
                Button(action: {
                    Task {
                        do {
                            _ = try await OpenAIAPI.createAssistant(
                                model: "gpt-4o-mini",
                                name: "Test Assistant",
                                description: "This is a test assistant.",
                                tools: nil,
                                instructions: "You are a test assistant.",
                                responseFormat: ResponseFormat())
                        } catch {
                            errorMessage = error.localizedDescription
                        }
                    }
                }) {
                    Text("Create assistant")
                }
                Button(action: {
                    Task {
                        await updateAssistantList()
                    }
                }) {
                    Text("Update assistant list")
                }
            }
        }
        .onAppear {
            Task {
                await updateAssistantList()
            }
        }
    }
    
    func updateAssistantList() async {
        do {
            assistants = try await OpenAIAPI.listAssistants()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
//    func deleteAllAssistants() async {
//        do {
//            // Fetch the list of all assistants (with pagination handled by listAssistants)
//            let assistantsArray = try await OpenAIAPI.listAssistants()
//
//            // Iterate over the assistants and delete each one
//            for assistant in assistantsArray {
//                if let id = assistant.id as String? {
//                    // Delete the assistant using the id
//                    let deleteResponse = try await OpenAIAPI.deleteAssistant(id: id)
//                    if let deleted = deleteResponse["deleted"] as? Bool, deleted {
//                        print("Deleted assistant with id: \(id)")
//                    } else {
//                        print("Failed to delete assistant with id: \(id)")
//                    }
//                }
//            }
//
//            print("Deleted all assistants")
//        } catch {
//            errorMessage = error.localizedDescription
//        }
//    }
}

#Preview {
    AssistantTestView()
}
