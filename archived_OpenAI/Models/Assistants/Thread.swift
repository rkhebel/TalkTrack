//
//  Thread.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 8/21/24.
//

import Foundation

class Thread: Codable {
    let id: String
    let object: String?
    var createdAt: Date
    var toolResources: ToolResources?
    var metadata: [String: String]?
    
    func update() {
        
    }
}
