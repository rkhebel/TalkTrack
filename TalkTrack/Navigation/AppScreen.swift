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
    
    var id: AppScreen { self }
}

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
            WorkoutRoutinesView()
        }
    }
}
