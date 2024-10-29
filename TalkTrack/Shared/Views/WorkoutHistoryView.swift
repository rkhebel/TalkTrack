//
//  WorkoutHistoryView.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 8/18/24.
//

import SwiftUI
import SwiftData

struct WorkoutHistoryView: View {
    @Query(
        filter: #Predicate<Workout> { workout in
            workout.typeRaw == "log" && workout.completed == true
        },
        sort: \Workout.createdDate
    ) var workouts: [Workout]
    
    var body: some View {
        List(workouts) { workout in
            WorkoutPreviewView(workout: workout)
        }
    }
}

#Preview {
    WorkoutHistoryView()
        .modelContainer(DataProvider.shared.previewContainer())
}
