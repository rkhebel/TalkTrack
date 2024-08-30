//
//  TalkTrackApp.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 8/18/24.
//

import SwiftUI
import SwiftOpenAI

@main
struct TalkTrackApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// Setting up global environment variables
extension EnvironmentValues {
    @Entry var openAIService: OpenAIService = OpenAIServiceFactory.service(apiKey: OpenAIAPIConfig.apiKey)
    @Entry var sharedDefaults: UserDefaults? = UserDefaults(suiteName: "com.ryanhebel.TalkTrack.SharedData")
}
