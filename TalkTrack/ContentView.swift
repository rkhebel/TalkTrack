//
//  ContentView.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 8/18/24.
//

import SwiftUI
@preconcurrency import SwiftOpenAI

struct ContentView: View {
    @Environment(\.openAIService) var openAIService
    @State private var selection: AppScreen? = .start
    
    var body: some View {
        AppTabView(selection: $selection)
            .onAppear {
                setupOpenAI()
            }
    }
//    
}

extension ContentView {
    private func setupOpenAI() {
        Task {
            do {
                try await setupAssistant()
            } catch APIError.responseUnsuccessful(let description, let statusCode) {
                print("Network error with status code: \(statusCode) and description: \(description)")
            } catch {
                print(error.localizedDescription)
             }
        }
    }

    private func setupAssistant() async throws {
        if UserDefaults(suiteName: "group.com.TalkTrack.SharedData")?.string(forKey: "assistantID") != nil {
        } else {
            let assistants = try await openAIService.listAssistants(limit: nil, order: nil, after: nil, before: nil)
            for assistant in assistants.data {
                if assistant.name == "development" {
                    UserDefaults(suiteName: "group.com.TalkTrack.SharedData")?.set(assistant.id, forKey: "assistantID")
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(DataProvider.shared.previewContainer())
}
