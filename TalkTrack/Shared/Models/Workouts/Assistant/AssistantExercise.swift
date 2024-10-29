//
//  AssistantExercise.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 9/6/24.
//

struct AssistantExercise: Codable {
    var name: String
    var sets: [AssistantExerciseSet]
    
    init(from exercise: Exercise) {
        self.name = exercise.name
        self.sets = exercise.sets.map { AssistantExerciseSet(from: $0) }
    }
}
