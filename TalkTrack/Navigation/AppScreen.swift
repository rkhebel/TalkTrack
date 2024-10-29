//
//  AppScreen.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 8/18/24.
//

import SwiftUI

enum AppScreen: Codable, Hashable, Identifiable, CaseIterable {
    case start
    case history
    case routines
    case chat
    case settings
    
    var id: AppScreen { self }
}

@MainActor
extension AppScreen {
    @ViewBuilder
    var label: some View {
        switch self {
        case .start:
            Label("Start", systemImage: "play.circle")
        case .history:
            Label("History", systemImage: "clock")
        case .routines:
            Label("Routines", systemImage: "list.bullet")
        case .chat:
            Label("Chat", systemImage: "message")
        case .settings:
            Label("Settings", systemImage: "gear")
        }
    }
    
    @ViewBuilder
    var destination: some View {
        switch self {
        case .start:
            StartWorkoutView()
        case .history:
            WorkoutHistoryView()
        case .routines:
            RoutineListView()
        case .chat:
            ChatPageView()
        case .settings:
            SettingsView()
        }
    }
}
