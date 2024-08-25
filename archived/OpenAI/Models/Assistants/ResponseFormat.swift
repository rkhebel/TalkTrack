//
//  ResponseFormat.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 8/21/24.
//

import Foundation

struct ResponseFormat: Codable {
    let type: ResponseFormatType
    let description: String?
    let name: String?
    let schema: Data?
    let strict: Bool?
    
    enum ResponseFormatType: String, Codable {
        case auto = "auto"
        case text = "text"
        case jsonObject = "json_object"
        case jsonSchema = "json_schema"
    }

    enum ResponseFormatError: LocalizedError {
        case missingRequiredField(String)
        case invalidOrMissingType
    }
    
    init() {
        self.type = ResponseFormatType.text
        self.description = nil
        self.name = nil
        self.schema = nil
        self.strict = nil
    }

    init(type: ResponseFormatType, description: String? = nil, name: String? = nil, schema: Data? = nil, strict: Bool? = nil) throws {
        self.type = type
        
        // Enforce required fields for json_schema
        if type == .jsonSchema {
            guard let description = description else {
                throw ResponseFormatError.missingRequiredField("description is required for json_schema")
            }
            guard let name = name else {
                throw ResponseFormatError.missingRequiredField("name is required for json_schema")
            }
            guard let schema = schema else {
                throw ResponseFormatError.missingRequiredField("schema is required for json_schema")
            }
            
            self.description = description
            self.name = name
            self.schema = schema
            self.strict = strict ?? true // Default to true if not provided
        } else {
            self.description = nil
            self.name = nil
            self.schema = nil
            self.strict = nil
        }
    }
}
