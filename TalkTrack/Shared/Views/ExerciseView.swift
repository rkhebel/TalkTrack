//
//  ExerciseView.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 8/30/24.
//

import SwiftUI

struct ExerciseView: View {
    @State var exercise: Exercise

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Exercise Name
            Text(exercise.name)
                .font(.title2)
                .bold()
                .padding(.bottom, 5)
                .foregroundColor(.primary)
            
            // Header Row
            HStack {
                Text("Set")
                    .font(.headline)
                    .frame(width: 50, alignment: .leading)
                Spacer()
                Text("Reps")
                    .font(.headline)
                    .frame(width: 60, alignment: .center)
                Spacer()
                Text("Weight (lbs)")
                    .font(.headline)
                    .frame(width: 100, alignment: .center)
            }
            .padding(.vertical, 4)
            
            Divider()

            ForEach(exercise.sets.indices, id: \.self) { index in
                if index < exercise.sets.count {
                    ExerciseSetView(exerciseSet: $exercise.sets[index], setNumber: index + 1)
                }
            }
        }
        .padding()
        .cornerRadius(10)
    }
}

#Preview {
    ExerciseView(exercise: Exercise.generateLogExercises()[0])
}
