//
//  LiveActivityManager.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 8/18/24.
//

import ActivityKit
import Foundation

class LiveActivityManager {
    
    static let shared = LiveActivityManager()
    
    private var currentActivity: Activity<TalkTrackWidgetAttributes>? = nil
    
    func startActivity() {
        if ActivityAuthorizationInfo().areActivitiesEnabled {
            do {
                let liveActivity = TalkTrackWidgetAttributes(name: "Test Activity")
                let initialState = TalkTrackWidgetAttributes.ContentState(
                    displayText: "Start Recording"
                )
                
                let activity = try Activity.request(
                    attributes: liveActivity,
                    content: ActivityContent(state: initialState, staleDate: nil),
                    pushType: nil
                )
                currentActivity = activity
            }
            catch {
                let errorMessage = """
                                Couldn't start activity
                                ------------------------
                                \(String(describing: error))
                                """
                print(errorMessage)
            }
        }
    }
    
    func updateActivity(displayText: String) async {
        guard let activity = currentActivity else {
            return
        }
        
        let contentState = TalkTrackWidgetAttributes.ContentState(
            displayText: displayText
        )
        
        await activity.update(
            ActivityContent(
                state: contentState,
                staleDate: nil
            )
        )
    }
    
    func endActivity() async {
        guard let activity = currentActivity else {
            return
        }
        
        let finalState = TalkTrackWidgetAttributes.ContentState(
            displayText: "Ending workout!"
        )
                
        await activity.end(ActivityContent(state: finalState, staleDate: nil), dismissalPolicy: .after(.now + 5))
        
    }
}
