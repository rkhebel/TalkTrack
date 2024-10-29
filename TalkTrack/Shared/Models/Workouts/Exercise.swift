//
//  Exercise.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 8/30/24.
//

import SwiftUI
import SwiftData

@Model
class Exercise: Identifiable, Codable {
    @Attribute(.unique) var id: UUID
    var createdDate: Date
    var name: String
    var workout: Workout?
    @Relationship(deleteRule: .cascade, inverse: \ExerciseSet.exercise)
    var sets: [ExerciseSet] = []
    
    init(name: String) {
        self.id = UUID()
        self.createdDate = Date()
        self.name = name
    }
    
    static func fromAssistant(assistantExercises: [AssistantExercise], context: ModelContext) -> [Exercise] {
        var exercises: [Exercise] = []
        
        for assistantExercise in assistantExercises {
            // Create the exercise object
            let exercise = Exercise(name: assistantExercise.name)
            
            // Create and insert sets for the exercise
            let exerciseSets = ExerciseSet.fromAssistant(assistantExerciseSets: assistantExercise.sets, context: context)
            exercise.sets.append(contentsOf: exerciseSets)
            
            // Insert the exercise into the context
            context.insert(exercise)
            
            // Add to the exercises list
            exercises.append(exercise)
        }
        
        return exercises
    }

    
    // Codable conformance
    enum CodingKeys: String, CodingKey {
        case id, createdDate, name, sets
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        createdDate = try container.decode(Date.self, forKey: .createdDate)
        name = try container.decode(String.self, forKey: .name)
        sets = try container.decode([ExerciseSet].self, forKey: .sets)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(createdDate, forKey: .createdDate)
        try container.encode(name, forKey: .name)
        try container.encode(sets, forKey: .sets)
    }
}


extension Exercise: Hashable {
    static func == (lhs: Exercise, rhs: Exercise) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


extension Exercise {
    // Generates exercises for template workouts (with rep ranges)
    static func generateTemplateExercises() -> [Exercise] {
        let exercises = [
            Exercise(name: "Bench Press"),
            Exercise(name: "Squat"),
            Exercise(name: "Deadlift")
        ]
        exercises[0].sets.append(contentsOf: ExerciseSet.generateTemplateSets())
        exercises[1].sets.append(contentsOf: ExerciseSet.generateTemplateSets())
        exercises[2].sets.append(contentsOf: ExerciseSet.generateTemplateSets())
        return exercises
    }

    // Generates exercises for log workouts that are just starting (no logged reps/weights)
    static func generateLogExercises() -> [Exercise] {
        let exercises = [
            Exercise(name: "Bench Press"),
            Exercise(name: "Squat"),
            Exercise(name: "Deadlift")
        ]
        exercises[0].sets.append(contentsOf: ExerciseSet.generateStartedLogSets())
        exercises[1].sets.append(contentsOf: ExerciseSet.generateStartedLogSets())
        exercises[2].sets.append(contentsOf: ExerciseSet.generateStartedLogSets())
        return exercises
    }

    // Generates exercises for completed log workouts (with reps and weights)
    static func generateCompletedLogExercises() -> [Exercise] {
        let exercises = [
            Exercise(name: "Bench Press"),
            Exercise(name: "Squat"),
            Exercise(name: "Deadlift")
        ]
        exercises[0].sets.append(contentsOf: ExerciseSet.generateCompletedLogSets())
        exercises[1].sets.append(contentsOf: ExerciseSet.generateCompletedLogSets())
        exercises[2].sets.append(contentsOf: ExerciseSet.generateCompletedLogSets())
        return exercises
    }
}

