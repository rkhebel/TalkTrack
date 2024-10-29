//
//  DataBase.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 9/12/24.
//

import SwiftData
import Foundation
import SwiftOpenAI

@ModelActor
public actor DataHandler {
    @MainActor
    public init(modelContainer: ModelContainer, mainActor _: Bool) {
        let modelContext = modelContainer.mainContext
        modelExecutor = DefaultSerialModelExecutor(modelContext: modelContext)
        self.modelContainer = modelContainer
    }
    
    // Generic fetch function for any PersistentModel type
    public func fetch<T: PersistentModel>(
        predicate: Predicate<T>? = nil,
        sortBy: [SortDescriptor<T>] = []
    ) throws -> [T] {
        let fetchDescriptor = FetchDescriptor<T>(predicate: predicate, sortBy: sortBy)
        return try modelContext.fetch(fetchDescriptor)
    }
    
    // Generic delete function
    func delete<T: PersistentModel>(id: PersistentIdentifier, as modelType: T.Type) throws {
        if let model = modelContext.model(for: id) as? T {
            modelContext.delete(model)
            try modelContext.save()
        } else {
            throw DataHandlerError.saveFailed("Failed to get PersistentIdentifier for \(modelType)")
        }
    }
    
    func addMessageToThread(conversationID: PersistentIdentifier, message: MessageObject) throws {
        guard let conversation = modelContext.model(for: conversationID) as? Conversation else {
            throw DataHandlerError.modelNotFound("Conversation not found for update")
        }
        if let chatMessage = ChatMessage(from: message) {
            conversation.addMessage(chatMessage)
            try modelContext.save()
        } else {
            throw DataHandlerError.invalidData("Failed to create chat message and add to conversation.")
        }
        
    }
}

extension DataHandler {
    func updateWorkoutFromAssistant(workoutID: PersistentIdentifier, assistantWorkout: AssistantWorkout) throws {
        guard let workout = modelContext.model(for: workoutID) as? Workout else {
            throw DataHandlerError.modelNotFound("Workout not found for update")
        }
        print("found workout")
        // Update workout name
        workout.name = "hardcode test" //assistantWorkout.name
        print("updated name")
        // Remove existing exercises
        workout.exercises.removeAll()
        print("removed exercises")
        // Add exercises from assistant data
        for assistantExercise in assistantWorkout.exercises {
            let exercise = try createExercise(from: assistantExercise, for: workout)
            print("created exercise")
            workout.exercises.append(exercise)
            print("appended exercise")
        }

        // Save changes
        try modelContext.save()
    }

    private func createExercise(from assistantExercise: AssistantExercise, for workout: Workout) throws -> Exercise {
        let exercise = Exercise(name: assistantExercise.name)
        exercise.workout = workout
        modelContext.insert(exercise)

        for assistantSet in assistantExercise.sets {
            let exerciseSet = try createExerciseSet(from: assistantSet, for: exercise)
            exercise.sets.append(exerciseSet)
        }

        return exercise
    }

    private func createExerciseSet(from assistantSet: AssistantExerciseSet, for exercise: Exercise) throws -> ExerciseSet {
        let exerciseSet = ExerciseSet(
            type: .log,
            reps: assistantSet.reps,
            weight: assistantSet.weight
        )
        exerciseSet.exercise = exercise
        modelContext.insert(exerciseSet)
        return exerciseSet
    }
}

extension DataHandler {
    enum DataHandlerError: Error {
        case modelNotFound(String)
        case saveFailed(String)
        case invalidData(String)
    }
}

