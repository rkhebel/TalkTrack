//
//  WorkoutRoutines.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 8/18/24.
//

import SwiftUI
import SwiftData

struct RoutineListView: View {
    @Query private var routines: [Routine]
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(routines) { routine in
                    NavigationLink(destination: RoutineDetailView(routine: routine)) {
                        RoutinePreviewView(routine: routine)
                    }
                }
                .onDelete(perform: deleteRoutine)
                .navigationTitle("Routines")
            }
            Spacer()
            NavigationLink {
                CreateRoutineView()
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Create Routine")
                        .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func deleteRoutine(at offsets: IndexSet) {
        offsets.forEach { index in
            modelContext.delete(routines[index])
        }
    }
}

struct RoutinePreviewView: View {
    @State var routine: Routine
    var body: some View {
        HStack {
            Text(routine.name)
                .font(.headline)
                .foregroundColor(.primary)
            Spacer()
            Text(routine.isCurrent ? "Active" : "Not active")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

struct CreateRoutineView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var routine: Routine = Routine(name: "")
    @State private var routineName: String = ""
    @State private var isCurrentRoutine: Bool = false
    @State private var showingCreateWorkout = false

    var body: some View {
        Form {
            TextField("Routine Name", text: $routineName)
            Toggle("Current Routine?", isOn: $isCurrentRoutine)
            Section(header: Text("Workouts")) {
                ForEach(routine.workouts) { workout in
                    Text(workout.name)
                }
                Button(action: {
                    showingCreateWorkout = true
                }) {
                    Text("Add Workout")
                }
                .sheet(isPresented: $showingCreateWorkout) {
                    CreateWorkoutView(routine: routine)
                }
            }
        }

        Button {
            routine.name = routineName
            context.insert(routine)
            if isCurrentRoutine {
                do {
                    try routine.markAsCurrent()
                } catch {
                    print("Error marking routine as current: \(error)")
                }
            }
            dismiss()
        } label: {
            Text("Create Routine")
        }
    }
}

struct CreateWorkoutView: View {
    @Environment(\.dismiss) private var dismiss
    var routine: Routine
    @State private var workoutName: String = ""
    @State private var workout: Workout = Workout(name: "", type: .template)
    @State private var showingAddExercise = false

    var body: some View {
        Form {
            TextField("Workout Name", text: $workoutName)
            
            Section(header: Text("Exercises")) {
                ForEach(workout.exercises) { exercise in
                    Text(exercise.name)
                }
                Button(action: {
                    showingAddExercise = true
                }) {
                    Text("Add Exercise")
                }
                .sheet(isPresented: $showingAddExercise) {
                    AddExerciseView(workout: workout)
                }
            }
        }

        Button {
            workout.name = workoutName
            routine.workouts.append(workout)
            dismiss()
        } label: {
            Text("Add Workout")
        }
    }
}

struct AddExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    var workout: Workout
    @State private var exerciseName: String = ""
    @State private var currentSetReps: Int = 10 // Reps for the current set being added
    @State private var currentExercise: Exercise? // Store the new exercise
    
    var body: some View {
        Form {
            TextField("Exercise Name", text: $exerciseName)
            
            Section(header: Text("Sets")) {
                if let exercise = currentExercise {
                    // Display existing sets in the current exercise
                    List(exercise.sets.indices, id: \.self) { index in
                        Text("Set \(index + 1): \(exercise.sets[index].reps) reps")
                    }
                } else {
                    Text("No sets added yet")
                }
                
                Stepper("Reps: \(currentSetReps)", value: $currentSetReps, in: 1...20)
                
                Button(action: {
                    addSetToExercise()
                }) {
                    Text("Add Set")
                        .foregroundColor(.blue)
                }
            }
        }

        Button {
            addExerciseToWorkout()
        } label: {
            Text("Add Exercise")
                .font(.headline)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
    }
    
    // Function to create and add sets to the exercise
    private func addSetToExercise() {
        if currentExercise == nil {
            // If the exercise hasn't been created yet, create it
            currentExercise = Exercise(name: exerciseName)
        }
        
        // Create a new set and add it to the current exercise
        let newSet = ExerciseSet(type: .template, reps: currentSetReps, weight: nil)
        currentExercise?.sets.append(newSet)
    }
    
    // Function to finalize the exercise and add it to the workout
    private func addExerciseToWorkout() {
        guard let exercise = currentExercise else { return } // Avoid adding an empty exercise
        workout.exercises.append(exercise)
        dismiss()
    }
}



struct RoutineDetailView: View {
    @State private var expandedWorkouts: Set<UUID> = []
    @State var routine: Routine
    
    var body: some View {
        Text(routine.isCurrent ? "Active" : "Not active")
        Form {
            Section(header: Text("Workouts")) {
                ForEach(routine.workouts) { workout in
                    WorkoutPreviewView(workout: workout)
                        .onTapGesture {
                            toggleWorkoutExpansion(workout)
                        }
                    
                    if expandedWorkouts.contains(workout.id) {
                        ForEach(workout.exercises) { exercise in
                            VStack(alignment: .leading) {
                                Text(exercise.name)
                                    .font(.headline)
                                ForEach(exercise.sets.indices, id: \.self) { index in
                                    Text("Set \(index + 1): \(exercise.sets[index].reps) reps: \(exercise.sets[index].id.uuidString)")
                                        .font(.subheadline)
                                }
                            }
                            .padding(.leading, 20)
                        }
                    }
                }
            }
        }
        .navigationTitle(routine.name)
    }
    
    private func toggleWorkoutExpansion(_ workout: Workout) {
        if expandedWorkouts.contains(workout.id) {
            expandedWorkouts.remove(workout.id)
        } else {
            expandedWorkouts.insert(workout.id)
        }
    }
}

struct WorkoutPreviewView: View {
    var workout: Workout
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(workout.name)
                .font(.title2)
                .padding(.vertical, 5)
            Text(workout.endTime ?? Date(), style: .relative)
            Text(workout.id.uuidString)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("\(workout.exercises.count) exercises")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 5)
    }
}


#Preview {
    RoutineListView()
        .modelContainer(DataProvider.shared.previewContainer())
}
