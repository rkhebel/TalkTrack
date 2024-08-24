//
//  FileManagerHelper.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 8/19/24.
//

import Foundation

struct FileManagerHelper {
    static func loadJSONToString(fileName: String, fileExtension: String) -> String {
        var jsonBlob: String = ""
        if let url = Bundle.main.url(forResource: "upper_lower_routine", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                jsonBlob = String(data: data, encoding: .utf8) ?? "Failed to load JSON"
            } catch {
                jsonBlob = "Error loading JSON: \(error.localizedDescription)"
            }
        } else {
            jsonBlob = "JSON file not found"
        }
        return jsonBlob
    }
}
