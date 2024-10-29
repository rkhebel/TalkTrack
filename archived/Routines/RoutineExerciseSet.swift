//
//  Set.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 8/30/24.
//

import SwiftUI
import SwiftData

@Model
class RoutineExerciseSet: Identifiable, Codable {
    var id: UUID
    var min_reps: Int
    var max_reps: Int
    
    init(id: UUID = UUID(), min_reps: Int, max_reps: Int) {
        self.id = id
        self.min_reps = min_reps
        self.max_reps = max_reps
    }
    
    // Codable conformance
    enum CodingKeys: String, CodingKey {
        case id, min_reps, max_reps
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        min_reps = try container.decode(Int.self, forKey: .min_reps)
        max_reps = try container.decode(Int.self, forKey: .max_reps)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(min_reps, forKey: .min_reps)
        try container.encode(max_reps, forKey: .max_reps)
    }
}

extension RoutineExerciseSet: Hashable {
    static func == (lhs: RoutineExerciseSet, rhs: RoutineExerciseSet) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension RoutineExerciseSet {
    static func sampleData() -> [RoutineExerciseSet] {
        return [
            RoutineExerciseSet(min_reps: 10, max_reps: 12),
            RoutineExerciseSet(min_reps: 8, max_reps: 10),
            RoutineExerciseSet(min_reps: 6, max_reps: 8)
        ]
    }
}
