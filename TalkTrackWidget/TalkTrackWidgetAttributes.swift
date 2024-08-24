//
//  TalkTrackWidgetAttributes.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 8/18/24.
//

import ActivityKit

struct TalkTrackWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var displayText: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}
