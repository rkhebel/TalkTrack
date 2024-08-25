//
//  Tools.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 8/23/24.
//

struct Tool: Codable {
    let type: ToolType
    let fileSearch: FileSearch?
    let function: Function?
    
    enum ToolType: String, Codable {
        case codeInterpreter = "code_interpreter"
        case fileSearch = "file_search"
        case function = "function"
    }
    
    struct FileSearch: Codable {
        let maxNumResults: Int
    }
    
    struct Function: Codable {
        let description: String
        let name: String
        let parameters: String // storing as string for simplicity, this should be JSON
        let strict: Bool?
    }
}
