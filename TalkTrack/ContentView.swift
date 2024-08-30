//
//  ContentView.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 8/18/24.
//

import SwiftUI
import SwiftOpenAI

struct ContentView: View {
    @Environment(\.openAIService) var openAIService
    @Environment(\.sharedDefaults) var sharedDefaults
    @State private var selection: AppScreen? = .start
    
    var body: some View {
        AppTabView(selection: $selection)
            .onAppear {
                setupOpenAI()
            }
    }
    
    private func setupOpenAI() {
        Task {
            do {
                try await setupAssistant()
                try await setupThread()
            } catch APIError.responseUnsuccessful(let description, let statusCode) {
                print("Network error with status code: \(statusCode) and description: \(description)")
             } catch {
                print(error.localizedDescription)
             }
        }
    }

    private func setupAssistant() async throws {
        if sharedDefaults?.string(forKey: "assistantID") != nil {
        } else {
            let assistants = try await openAIService.listAssistants(limit: nil, order: nil, after: nil, before: nil)
            for assistant in assistants.data {
                if assistant.name == "development" {
                    sharedDefaults?.set(assistant.id, forKey: "assistantID")
                }
            }
        }
    }
    
    private func setupThread() async throws {
        if sharedDefaults?.string(forKey: "threadID") != nil {
        } else {
            // Initialize the vector store
            let vectorStore = ToolResources.FileSearch.VectorStore(
                fileIDS: [], // Start with an empty list, you can add file IDs later
                chunkingStrategy: .auto, // Use auto chunking strategy
                metadata: nil // Any metadata if necessary
            )

            // Initialize the file search with the vector store
            let fileSearch = ToolResources.FileSearch(
                vectorStoreIds: nil, // This would be filled after the vector store is created
                vectorStores: [vectorStore]
            )

            // Initialize tool resources with the file search
            let toolResources = ToolResources(fileSearch: fileSearch)

            // Initialize the parameters for creating a thread
            let parameters = CreateThreadParameters(toolResources: toolResources)
            let threadObject: ThreadObject = try await openAIService.createThread(parameters: parameters)
            sharedDefaults?.set(threadObject.id, forKey: "threadID")
        }
    }
}

#Preview {
    ContentView()
}
