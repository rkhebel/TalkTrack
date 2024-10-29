//
//  CurrentWorkoutView.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 8/18/24.
//

import SwiftUI
import SwiftOpenAI

struct CurrentWorkoutView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.openAIService) var openAIService
    @State private var isSheetPresented: Bool = false
    @State var currentWorkout: Workout
    @State var conversation: Conversation
    @State private var navigateToCompleted = false // State to trigger navigation
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Button("Minimize", systemImage: "chevron.down"){
                        dismiss()
                    }
                    .labelStyle(.iconOnly)
                    .padding([.leading, .trailing], 20)
                    Text(currentWorkout.name)
                        .bold()
                        .frame(maxWidth: 200)
                        .truncationMode(.tail)
                        .lineLimit(1)
                    Spacer()
                    Button(action: {
                        do {
                            try currentWorkout.completeWorkout()
                            let encoder = JSONEncoder()
                            let jsonData = try encoder.encode(currentWorkout)
                            if let jsonString = String(data: jsonData, encoding: .utf8) {
                                print(jsonString)
                            }
                            navigateToCompleted = true
                        } catch {
                            print("Couldn't complete workout: \(error.localizedDescription)")
                        }
                    }) {
                        Text("Finish")
                    }
                    .padding([.trailing], 20)
                }
                
                ScrollView {
                    ForEach(currentWorkout.exercises) { exercise in
                        ExerciseView(exercise: exercise)
                    }
                }
                Spacer()
                Button(action: {
                    withAnimation {
                        isSheetPresented.toggle()
                    }
                }) {
                    HStack {
                        Text("Conversation")
                        Image(systemName: "chevron.up")
                            .font(.system(size: 12, weight: .bold))
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .clipShape(Circle())
                    }
                }
                // Navigation to CompletedWorkoutView
                NavigationLink(
                    destination: CompletedWorkoutView(parentDismiss: dismiss),
                    isActive: $navigateToCompleted
                ) {
                    EmptyView()
                }
            }
            .sheet(isPresented: $isSheetPresented) {
                ConversationView(conversation: conversation, openAIService: openAIService)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
        
    }
}


#Preview {
    let container = DataProvider.shared.previewContainer()
    let currentWorkout = Workout.generateStartedLogWorkout()
    container.mainContext.insert(currentWorkout)
    return CurrentWorkoutView(currentWorkout: Workout.generateStartedLogWorkout(), conversation: Conversation.sampleConversation())
        .modelContainer(DataProvider.shared.previewContainer())
}


