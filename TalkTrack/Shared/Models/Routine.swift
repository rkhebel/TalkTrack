//
//  Routine.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 8/19/24.
//

import SwiftUI

struct Routine: Identifiable {
    var id = UUID()
    var createdDate: Date
    var name: String
    var jsonBlob: String
}
