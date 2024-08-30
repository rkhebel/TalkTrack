//
//  CurrentWorkoutView.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 8/18/24.
//

import SwiftUI
import SwiftOpenAI

struct CurrentWorkoutView: View {
    @Environment(\.openAIService) var openAIService
    @AppStorage("threadID", store: UserDefaults(suiteName: "com.ryanhebel.TalkTrack.SharedData")) var threadID: String = "defaultThread"
    @AppStorage("assistantID", store: UserDefaults(suiteName: "com.ryanhebel.TalkTrack.SharedData")) var assistantID: String = "defaultAssistant"
    @State private var isSheetPresented: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Your current workout content
            VStack {
                Text("Current Workout")
                    .font(.largeTitle)
                    .padding()
                Spacer()
            }
            
            // Conversation sheet handle
            VStack {
                Button(action: {
                    withAnimation {
                        isSheetPresented.toggle()
                    }
                }) {
                    Image(systemName: isSheetPresented ? "chevron.down" : "chevron.up")
                        .font(.system(size: 24, weight: .bold))
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .clipShape(Circle())
                }
                .padding(.bottom, 8)
                
                Spacer() // Pushes the rest of the content up
            }
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(radius: 10)
            .offset(y: isSheetPresented ? 0 : UIScreen.main.bounds.height * 0.8) //
        }
        .edgesIgnoringSafeArea(.all)
        .sheet(isPresented: $isSheetPresented) {
            ConversationView(openAIService: openAIService, threadID: threadID, assistantID: assistantID)
        }

    }
}


#Preview {
    CurrentWorkoutView()
}


