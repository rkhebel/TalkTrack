//
//  Set.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 8/30/24.
//

import Foundation
import SwiftData

@Model
class ExerciseSet: Identifiable, Codable {
    // Enum to control whether it's a template or log
    enum SetType: String, Codable {
        case template
        case log
    }
    // Enum for controlling type
    var type: SetType
    
    // Shared variables
    @Attribute(.unique) var id: UUID = UUID()
    var createdDate: Date = Date()
    var exercise: Exercise?
    
    // Template-specific variables
//    struct RepRange: Codable, CustomStringConvertible {
//        var min: Int
//        var max: Int
//        
//        var description: String {
//            return "\(min) - \(max)"
//        }
//    }
//    var repRange: RepRange?
    
    // Log-specific variables
    var reps: Int?
    var weight: Double?
    var completed: Bool?
    
    // Initializer for log
    init(type: SetType, reps: Int?, weight: Double?) {
        self.type = type
        self.reps = reps
        self.weight = weight
    }
    
    static func fromAssistant(assistantExerciseSets: [AssistantExerciseSet], context: ModelContext) -> [ExerciseSet] {
        var exerciseSets: [ExerciseSet] = []
        
        for assistantExerciseSet in assistantExerciseSets {
            let exerciseSet = ExerciseSet(type: .log, reps: assistantExerciseSet.reps ?? 0, weight: assistantExerciseSet.weight ?? 0)
            
            // Insert the ExerciseSet into the SwiftData context
            context.insert(exerciseSet)
            
            // Add the created exerciseSet to the array
            exerciseSets.append(exerciseSet)
        }
        
        return exerciseSets
    }
    
    // Codable conformance
    enum CodingKeys: String, CodingKey {
        case id, createdDate, type, repRange, reps, weight
    }
    
    // Decoding logic remains the same, depending on how the encoded data is structured
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        createdDate = try container.decode(Date.self, forKey: .createdDate)
        type = try container.decode(SetType.self, forKey: .type)
        reps = try container.decodeIfPresent(Int.self, forKey: .reps)
        weight = try container.decodeIfPresent(Double.self, forKey: .weight)
    }
    
    // Conditional encoding based on SetType
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(createdDate, forKey: .createdDate)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(reps, forKey: .reps)
        try container.encodeIfPresent(weight, forKey: .weight)
    }
    
    // Static method to find a Routine by id
    static func find(id: UUID, context: ModelContext?) throws -> ExerciseSet? {
        let predicate = #Predicate { (exerciseSet: ExerciseSet) in
            exerciseSet.id == id
        }
        let result = try context?.fetch(FetchDescriptor<ExerciseSet>(predicate: predicate))
        return result?.first
    }
    
    // update to pull last exercise data
    func createLog() -> ExerciseSet {
        let exerciseSetLog = ExerciseSet(type: .log, reps: self.reps, weight: self.weight)
        return exerciseSetLog
    }
}

extension ExerciseSet: Hashable {
    static func == (lhs: ExerciseSet, rhs: ExerciseSet) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension ExerciseSet {
    // Generates sets for template workouts
    static func generateTemplateSets() -> [ExerciseSet] {
        return [
            ExerciseSet(type: .template, reps: 12, weight: nil),
            ExerciseSet(type: .template, reps: 10, weight: nil),
            ExerciseSet(type: .template, reps: 8, weight: nil)
        ]
    }

    // Generates sets for log workouts that are being started (no reps/weight yet)
    static func generateStartedLogSets() -> [ExerciseSet] {
        return [
            ExerciseSet(type: .log, reps: nil, weight: nil),
            ExerciseSet(type: .log, reps: nil, weight: nil),
            ExerciseSet(type: .log, reps: nil, weight: nil)
        ]
    }

    // Generates sets for completed log workouts (with reps and weight)
    static func generateCompletedLogSets() -> [ExerciseSet] {
        return [
            ExerciseSet(type: .log, reps: 10, weight: 100.0),
            ExerciseSet(type: .log, reps: 8, weight: 110.0),
            ExerciseSet(type: .log, reps: 6, weight: 120.0)
        ]
    }
}

