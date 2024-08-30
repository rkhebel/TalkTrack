//
//  WorkoutRoutines.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 8/18/24.
//

import SwiftUI

struct RoutineListView: View {
    @State private var jsonBlob: String = FileManagerHelper.loadJSONToString(fileName: "upper_lower_routine", fileExtension: "json")
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text(jsonBlob)
                    .font(.body)
                    .padding()
            }
            .navigationTitle("Workout Routines")
        }
    }
}

#Preview {
    RoutineListView()
}
