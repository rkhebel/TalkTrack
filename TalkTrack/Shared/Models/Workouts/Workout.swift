//
//  Workout.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 8/30/24.
//

import SwiftUI
import SwiftData

@Model
class Workout: Identifiable, Codable {
    enum WorkoutType: String, Codable {
        case template
        case log
    }
    // controls whether workout is template or log
    var type: WorkoutType {
        get {
            WorkoutType(rawValue: typeRaw) ?? .template
        }
        set {
            typeRaw = newValue.rawValue
        }
    }
    private(set) var typeRaw: WorkoutType.RawValue = WorkoutType.template.rawValue
    
    //shared vars
    @Attribute(.unique) var id: UUID = UUID()
    var createdDate: Date = Date()
    var name: String
    var routine: Routine?
    @Relationship(deleteRule: .nullify, inverse: \Exercise.workout)
    var exercises: [Exercise] = []
    
    // vars only if type == .log
    private(set) var isCurrent: Bool?
    var startTime: Date?
    var endTime: Date?
    var completed: Bool?
    
    init(name: String, type: WorkoutType) {
        self.name = name
        self.type = type
    }

    static func fromAssistant(assistantWorkout: AssistantWorkout, context: ModelContext) -> Workout {
        // Create the workout object
        let workout = Workout(name: assistantWorkout.name, type: .log)
        
        // Create and insert exercises for the workout
        let exercises = Exercise.fromAssistant(assistantExercises: assistantWorkout.exercises, context: context)
        workout.exercises.append(contentsOf: exercises)
        
        // Insert the workout into the context
        context.insert(workout)
        
        return workout
    }
    
    // Codable conformance
    enum CodingKeys: String, CodingKey {
        case id, createdDate, name, exercises, type, isCurrent, startTime, endTime, completed
    }

    // Decoding based on WorkoutType
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        createdDate = try container.decode(Date.self, forKey: .createdDate)
        name = try container.decode(String.self, forKey: .name)
        exercises = try container.decode([Exercise].self, forKey: .exercises)
        type = try container.decode(WorkoutType.self, forKey: .type)

        // Conditionally decode log-specific fields
        if type == .log {
            isCurrent = try container.decodeIfPresent(Bool.self, forKey: .isCurrent)
            startTime = try container.decodeIfPresent(Date.self, forKey: .startTime)
            endTime = try container.decodeIfPresent(Date.self, forKey: .endTime)
            completed = try container.decodeIfPresent(Bool.self, forKey: .completed)
        }
    }

    // Encoding based on WorkoutType
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(createdDate, forKey: .createdDate)
        try container.encode(name, forKey: .name)
        try container.encode(exercises, forKey: .exercises)
        try container.encode(type, forKey: .type)

        // Conditionally encode log-specific fields
        if type == .log {
            try container.encodeIfPresent(isCurrent, forKey: .isCurrent)
            try container.encodeIfPresent(startTime, forKey: .startTime)
            try container.encodeIfPresent(endTime, forKey: .endTime)
            try container.encodeIfPresent(completed, forKey: .completed)
        }
    }
    
    func markAsCurrent() throws {
        guard let modelContext = self.modelContext else {
            print("Failed to fetch model context while marking workout as current.")
            return
        }

        // Fetch all routines marked as current and unmark them
        try modelContext.fetch(FetchDescriptor<Workout>(predicate: #Predicate<Workout> { $0.isCurrent == true }))
            .forEach { $0.isCurrent = false }

        // Mark this routine as current
        self.isCurrent = true
    }
    
    // Static method to find a Workout by id
    static func find(id: UUID, context: ModelContext?) throws -> Workout? {
        let predicate = #Predicate { (workout: Workout) in
            workout.id == id
        }
        let result = try context?.fetch(FetchDescriptor<Workout>(predicate: predicate))
        return result?.first
    }
    
    // Logic to convert a template to a logged workout
    func createLogAndStart(context: ModelContext) throws -> Workout {
        let workoutLog = createLog(context: context)
        try workoutLog.startWorkout()
        return workoutLog
    }
    
    private func createLog(context: ModelContext) -> Workout {
        let workoutLog = Workout(name: self.name, type: .log)
        context.insert(workoutLog)
        workoutLog.routine = self.routine
        workoutLog.isCurrent = false
        self.completed = false
        for exercise in self.exercises {
            let exerciseLog = Exercise(name: exercise.name)
            for set in exercise.sets {
                let exerciseSetLog = set.createLog()
                exerciseLog.sets.append(exerciseSetLog)
            }
            workoutLog.exercises.append(exerciseLog)
        }
        return workoutLog
    }
    
    private func startWorkout() throws {
        guard self.type == .log else {
            throw WorkoutError.invalidType(operation: "startWorkout", type: self.type)
        }
        self.startTime = Date()
        self.isCurrent = true
    }
    
    func completeWorkout() throws {
        guard self.type == .log else {
            throw WorkoutError.invalidType(operation: "completeWorkout", type: self.type)
        }
        self.endTime = Date()
        self.completed = true
    }
}

extension Workout {
    enum WorkoutError: LocalizedError {
        case invalidType(operation: String, type: WorkoutType)
        
        var errorDescription: String? {
            switch self {
            case .invalidType(let operation, let type):
                return "Atttempted to: \(operation) with an invalid workout of type: \(type)."
            }
        }
    }
    
}

extension Workout: Hashable {
    static func == (lhs: Workout, rhs: Workout) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Workout {
    // Generates template workouts (used as templates for logging)
    static func generateTemplateWorkout() -> Workout {
        let workout = Workout(
            name: "Full Body Workout",
            type: .template
        )
        workout.exercises.append(contentsOf: Exercise.generateTemplateExercises())
        return workout
    }

    // Generates a log workout that is just being started (no completion)
    static func generateStartedLogWorkout() -> Workout {
        let workout = Workout(
            name: "Upper Body Workout - In Progress",
            type: .log
        )
        workout.startTime = Date()
        workout.isCurrent = true
        workout.completed = false
        workout.exercises.append(contentsOf: Exercise.generateLogExercises())
        return workout
    }

    // Generates a completed log workout with reps and weights
    static func generateCompletedLogWorkout() -> Workout {
        let workout = Workout(
            name: "Lower Body Workout - Completed",
            type: .log
        )
        workout.startTime = Date().addingTimeInterval(-3600) // 1 hour ago
        workout.endTime = Date()
        workout.isCurrent = false
        workout.completed = true
        workout.exercises.append(contentsOf: Exercise.generateCompletedLogExercises())
        return workout
    }
}

