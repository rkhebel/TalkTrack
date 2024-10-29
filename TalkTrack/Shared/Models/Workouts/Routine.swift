//
//  Routine.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 8/19/24.
//

import SwiftUI
import SwiftData

@Model
class Routine: Identifiable, Codable {
    @Attribute(.unique) var id: UUID
    var createdDate: Date
    var name: String
    @Relationship(deleteRule: .nullify, inverse: \Workout.routine)
    var workouts: [Workout] = []
    private(set) var isCurrent: Bool = false
    
    init(name: String) {
        self.id = UUID()
        self.createdDate = Date()
        self.name = name
    }
    
    // Codable conformance
    enum CodingKeys: String, CodingKey {
        case id, createdDate, name, workouts, isCurrent
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        createdDate = try container.decode(Date.self, forKey: .createdDate)
        name = try container.decode(String.self, forKey: .name)
        workouts = try container.decode([Workout].self, forKey: .workouts)
        isCurrent = try container.decode(Bool.self, forKey: .isCurrent)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(createdDate, forKey: .createdDate)
        try container.encode(name, forKey: .name)
        try container.encode(workouts, forKey: .workouts)
        try container.encode(isCurrent, forKey: .isCurrent)
    }
    
    func markAsCurrent() throws {
        guard let modelContext = self.modelContext else {
            print("Failed to fetch model context while marking Routine as current.")
            return
        }

        // Fetch all routines marked as current and unmark them
        try modelContext.fetch(FetchDescriptor<Routine>(predicate: #Predicate<Routine> { $0.isCurrent == true }))
            .forEach { $0.isCurrent = false }

        // Mark this routine as current
        self.isCurrent = true
    }
    
    // Static method to find a Routine by id
    static func find(id: UUID, context: ModelContext?) throws -> Routine? {
        let predicate = #Predicate { (routine: Routine) in
            routine.id == id
        }
        let result = try context?.fetch(FetchDescriptor<Routine>(predicate: predicate))
        return result?.first
    }
}

extension Routine: Hashable {
    static func == (lhs: Routine, rhs: Routine) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


extension Routine {
    static func sampleData(isCurrent: Bool = true) -> Routine {
        let routine = Routine(
            name: "Sample Routine"
        )
        routine.workouts.append(Workout.generateTemplateWorkout())
        routine.isCurrent = isCurrent
        return routine
    }
}
