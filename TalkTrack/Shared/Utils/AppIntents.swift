//
//  AppIntents.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 8/18/24.
//

import AppIntents
import WidgetKit

// intent to start recording
struct StartRecordingIntent: LiveActivityIntent, AudioRecordingIntent {
    static var title: LocalizedStringResource = "Start Recording"
    static var description: IntentDescription = "Start recording audio"
    
    func perform() async throws -> some IntentResult {
        await SpeechRecognizer.shared.startTranscribing()
        return .result()
    }
}


// intent to stop recording
struct StopRecordingIntent: LiveActivityIntent, AudioRecordingIntent {
    static var title: LocalizedStringResource = "Stop Recording"
    static var description: IntentDescription = "Stop recording audio"
    
    func perform() async throws -> some IntentResult {
        let transcript = await SpeechRecognizer.shared.stopTranscribing()
        await LiveActivityManager.shared.updateActivity(displayText: transcript)
        return .result()
    }
}


//intent to end activity
struct EndActivityIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "End Activity"
    static var description: IntentDescription = "End the current activity"
    
    func perform() async throws -> some IntentResult {
        await LiveActivityManager.shared.endActivity()
        return .result()
    }
}




