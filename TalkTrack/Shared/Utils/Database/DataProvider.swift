//
//  DataProvider.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 9/12/24.
//

import SwiftData

// this class creates the ModelContainer and a shared singleton for data access across the whole app
public final class DataProvider: Sendable {
    public static let shared = DataProvider()
    
    public let modelContainer: ModelContainer = {
        let schema = Schema([Routine.self, Conversation.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Failed to create model container: \(error)")
        }
    }()
    
    @MainActor
    func previewContainer() -> ModelContainer {
        do {
            let schema = Schema([Routine.self, Conversation.self])
            let container = try ModelContainer(
                for: schema,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )
            container.mainContext.insert(Routine.sampleData())
            return container
        } catch {
            fatalError("Failed to initialize model container: \(error)")
        }
    }
    
    // Create DataHandler based on preview flag
    @MainActor
    public func dataHandler(preview: Bool = false) -> DataHandler {
        let container = preview ? previewContainer() : modelContainer
        return DataHandler(modelContainer: container, mainActor: true)
    }
    
    public init() {}
}



