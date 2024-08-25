//
//  ContentView.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 8/18/24.
//

import SwiftUI
import SwiftOpenAI

struct ContentView: View {
    @State private var selection: AppScreen? = .start
    @Environment(\.openAIService) var openAIService
    
    var body: some View {
        Text("TalkTrack")
            .font(.title)
        AppTabView(selection: $selection)
    }
}



#Preview {
    ContentView()
}
