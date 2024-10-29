//
//  StartWorkoutView.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 8/18/24.
//

import SwiftUI
import SwiftData
import SwiftOpenAI

struct StartWorkoutView: View {
    @Environment(\.modelContext) private var context: ModelContext
    @Environment(\.openAIService) private var openAIService
    @AppStorage("assistantID", store: UserDefaults(suiteName: "group.com.TalkTrack.SharedData")) var assistantID: String = "defaultAssistant"
    @State private var isActive = false
    @Query(
        filter: #Predicate<Workout> { workout in
            workout.typeRaw == "template" && (workout.routine?.isCurrent == true)
        },
        sort: \Workout.createdDate
    ) var templateWorkouts: [Workout]
    @State private var newWorkout: Workout? // This will hold the new workout for the CurrentWorkoutView
    @State private var selectedWorkout: Workout?
    @State private var conversation: Conversation?
    
    var body: some View {
        VStack {
            if !templateWorkouts.isEmpty {
                List(templateWorkouts, id: \.self, selection: $selectedWorkout) { workout in
                    WorkoutPreviewView(workout: workout)
                }
                .navigationTitle("Select Workout")
            } else {
                Text("No template workouts found.")
            }
            Spacer()
            // Start Workout button
            Button(action: {
                Task {
                    await startWorkout()
                }
            }) {
                Text("Start Workout")
                    .font(.headline)
                    .padding()
                    .background(selectedWorkout != nil ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .disabled(selectedWorkout == nil) // Disable the button if no workout is selected
        }
        .fullScreenCover(item: $newWorkout) { workout in
            if let conversation = conversation {
                CurrentWorkoutView(currentWorkout: workout, conversation: conversation)
            }
        }
    }
    
    func startWorkout() async {
        guard let selectedWorkout = selectedWorkout else { return }

        do {
            newWorkout = try selectedWorkout.createLogAndStart(context: context)
        } catch {
            print("Failed to start workout: \(error)")
        }
        
        do {
            conversation = await Conversation(openAIService: openAIService, messages: nil, assistantID: assistantID)

            let encoder = JSONEncoder()
            guard let newWorkout = newWorkout else { return }
            let assistantWorkout = AssistantWorkout(from: newWorkout)
            // Encode the Workout object to JSON data
            let jsonData = try encoder.encode(assistantWorkout)
            
            // Convert the JSON data to a string
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                let messageContent = "The user is going to start a workout based on the following template. Please help them log their workout by updating exercises and sets. \(jsonString)"
                
                print(messageContent)
                let params = MessageParameter(
                    role: .user,
                    content: messageContent,
                    metadata: [
                        "hidden": "true"
                    ]
                )
                if let conversation = conversation {
                    try await openAIService.createMessage(threadID: conversation.openAIID, parameters: params)
                }
            }
        } catch {
            print("Failed to create thread with workout: \(error)")
        }
    }
}

#Preview {
    StartWorkoutView()
        .modelContainer(DataProvider.shared.previewContainer())
}
