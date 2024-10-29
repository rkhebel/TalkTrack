//
//  Exercise.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 8/30/24.
//

import SwiftUI
import SwiftData

@Model
class RoutineExercise: Identifiable, Codable {
    var id: UUID
    var createdDate: Date
    var name: String
    var sets: [RoutineExerciseSet]
    
    init(id: UUID = UUID(), createdDate: Date = Date(), name: String, sets: [RoutineExerciseSet]) {
        self.id = id
        self.createdDate = createdDate
        self.name = name
        self.sets = sets
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
        sets = try container.decode([RoutineExerciseSet].self, forKey: .sets)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(createdDate, forKey: .createdDate)
        try container.encode(name, forKey: .name)
        try container.encode(sets, forKey: .sets)
    }
}


extension RoutineExercise: Hashable {
    static func == (lhs: RoutineExercise, rhs: RoutineExercise) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


extension RoutineExercise {
    static func sampleData() -> [RoutineExercise] {
        return [
            RoutineExercise(
                createdDate: Date(),
                name: "Bench Press",
                sets: RoutineExerciseSet.sampleData()
            ),
            RoutineExercise(
                createdDate: Date(),
                name: "Squat",
                sets: RoutineExerciseSet.sampleData()
            ),
            RoutineExercise(
                createdDate: Date(),
                name: "Deadlift",
                sets: RoutineExerciseSet.sampleData()
            )
        ]
    }
}
