//
//  ContentView.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 8/18/24.
//

import SwiftUI

struct ContentView: View {
    @State private var selection: AppScreen? = .start
    
    var body: some View {
        Text("TalkTrack")
            .font(.title)
        AppTabView(selection: $selection)
    }
}

#Preview {
    ContentView()
}
