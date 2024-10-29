//
//  ExerciseSetView.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 8/30/24.
//

import SwiftUI

struct ExerciseSetView: View {
    @Binding var exerciseSet: ExerciseSet
    let setNumber: Int

    var body: some View {
        HStack {
            Text("Set \(setNumber)")
                .font(.headline)
                .frame(width: 50, alignment: .leading)

            Spacer()

            TextField("Reps", value: $exerciseSet.reps, formatter: NumberFormatter())
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
                .frame(width: 60)

            Spacer()

            TextField("Weight (lbs)", value: $exerciseSet.weight, formatter: NumberFormatter())
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
                .frame(width: 100)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}
