//
//  AssistantWorkout.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 9/6/24.
//

struct AssistantWorkout: Codable {
    var name: String
    var exercises: [AssistantExercise]
    
    init(from workout: Workout) {
        self.name = workout.name
        self.exercises = workout.exercises.map { AssistantExercise(from: $0) }
    }
}
