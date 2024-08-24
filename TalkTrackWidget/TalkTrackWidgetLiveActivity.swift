//
//  TalkTrackWidgetLiveActivity.swift
//  TalkTrackWidget
//
//  Created by Ryan Hebel on 8/18/24.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct TalkTrackWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TalkTrackWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text(context.state.displayText)
                HStack {
                    Button(intent: StartRecordingIntent()) {
                        Image(systemName: "mic")
                    }
                    Button(intent: StopRecordingIntent()) {
                        Image(systemName: "mic.slash")
                    }
                    Button(intent: EndActivityIntent()) {
                        Image(systemName: "stop.circle")
                    }
                }
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.displayText)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.displayText)")
            } minimal: {
                Text(context.state.displayText)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension TalkTrackWidgetAttributes {
    fileprivate static var preview: TalkTrackWidgetAttributes {
        TalkTrackWidgetAttributes(name: "World")
    }
}

extension TalkTrackWidgetAttributes.ContentState {
    fileprivate static var smiley: TalkTrackWidgetAttributes.ContentState {
        TalkTrackWidgetAttributes.ContentState(displayText: "😀")
     }
     
     fileprivate static var starEyes: TalkTrackWidgetAttributes.ContentState {
         TalkTrackWidgetAttributes.ContentState(displayText: "🤩")
     }
}

#Preview("Notification", as: .content, using: TalkTrackWidgetAttributes.preview) {
   TalkTrackWidgetLiveActivity()
} contentStates: {
    TalkTrackWidgetAttributes.ContentState.smiley
    TalkTrackWidgetAttributes.ContentState.starEyes
}
