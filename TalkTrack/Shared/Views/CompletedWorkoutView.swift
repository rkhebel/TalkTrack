//
//  CompletedWorkoutView.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 9/11/24.
//

import SwiftUI

struct CompletedWorkoutView: View {
    let parentDismiss: DismissAction
    
    var body: some View {
        VStack {
            Text("Congratulations on completing your workout!")
                .font(.largeTitle)
                .multilineTextAlignment(.center)
                .padding()

            Button(action: {
                parentDismiss()
            }) {
                Text("Done")
                    .font(.title2)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .navigationBarBackButtonHidden(true) // Optionally hide the back button
    }
}
