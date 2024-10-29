//
//  AssistantExerciseSet.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 9/6/24.
//

struct AssistantExerciseSet: Codable {
    var reps: Int?
    var weight: Double?
    
    init(from set: ExerciseSet) {
        self.reps = set.reps
        self.weight = set.weight
    }
}
