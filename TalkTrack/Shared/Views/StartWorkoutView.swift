//
//  StartWorkoutView.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 8/18/24.
//

import SwiftUI

struct StartWorkoutView: View {
    @State private var isActive = false
    
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: CurrentWorkoutView().navigationBarBackButtonHidden(true), isActive: $isActive) {
                    Button(action: {
                        LiveActivityManager.shared.startActivity()
                        isActive = true
                    }) {
                        Text("Start Workout")
                    }
                }
            }
        }
    }
}

#Preview {
    StartWorkoutView()
}
