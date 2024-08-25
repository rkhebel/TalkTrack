//
//  OpenAITestView.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 8/24/24.
//


import SwiftUI
import SwiftOpenAI

struct OpenAITestView: View {
    let service: OpenAIService = OpenAIServiceFactory.service(apiKey: OpenAIAPIConfig.apiKey)
    
    var body: some View {
        Text("OpenAI Test View")
    }
}

#Preview {
    OpenAITestView()
}
