//
//  Workout.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 8/30/24.
//

import SwiftUI
import SwiftData

@Model
class RoutineWorkout: Identifiable, Codable {
    var id: UUID
    var createdDate: Date
    var name: String
    var exercises: [RoutineExercise]
    
    init(id: UUID = UUID(), createdDate: Date = Date(), name: String, exercises: [RoutineExercise]) {
        self.id = id
        self.createdDate = createdDate
        self.name = name
        self.exercises = exercises
    }
    
    // Codable conformance
    enum CodingKeys: String, CodingKey {
        case id, createdDate, name, exercises
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        createdDate = try container.decode(Date.self, forKey: .createdDate)
        name = try container.decode(String.self, forKey: .name)
        exercises = try container.decode([RoutineExercise].self, forKey: .exercises)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(createdDate, forKey: .createdDate)
        try container.encode(name, forKey: .name)
        try container.encode(exercises, forKey: .exercises)
    }

}

extension RoutineWorkout: Hashable {
    static func == (lhs: RoutineWorkout, rhs: RoutineWorkout) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension RoutineWorkout {
    static func sampleData() -> [RoutineWorkout] {
        return [
            RoutineWorkout(
                createdDate: Date(),
                name: "Upper Body Workout",
                exercises: RoutineExercise.sampleData()
            ),
            RoutineWorkout(
                createdDate: Date(),
                name: "Lower Body Workout",
                exercises: RoutineExercise.sampleData()
            )
        ]
    }
}
