//
//  OpenAIAPIConfig.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 8/25/24.
//

import Foundation

struct OpenAIAPIConfig {
    static var apiKey: String {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "OpenAI_API_Key") as? String else {
            fatalError("API Key not found in Info.plist")
        }
        return apiKey
    }
}
