//
//  TalkTrackWidgetBundle.swift
//  TalkTrackWidget
//
//  Created by Ryan Hebel on 8/18/24.
//

import WidgetKit
import SwiftUI

@main
struct TalkTrackWidgetBundle: WidgetBundle {
    var body: some Widget {
        TalkTrackWidget()
        TalkTrackWidgetLiveActivity()
    }
}
