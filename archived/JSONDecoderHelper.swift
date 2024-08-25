//
//  JSONDecoderHelper.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 8/23/24.
//

// This exists if I ever want to use safer decoding, don't want to complicate my code right now but in case I need it it's here.

import Foundation

struct JSONDecoderHelper {
    
    static func decode<T: Decodable>(_ type: T.Type, from data: Data) -> Result<T, DecodingError> {
        let decoder = JSONDecoder()
        
        do {
            let decodedObject = try decoder.decode(T.self, from: data)
            return .success(decodedObject)
        } catch let error as DecodingError {
            printDetailedError(error)
            return .failure(error)
        } catch {
            // Handle unexpected errors
            print("Unexpected error: \(error.localizedDescription)")
            return .failure(.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: error.localizedDescription)))
        }
    }
    
    private static func printDetailedError(_ error: DecodingError) {
        switch error {
        case .typeMismatch(let type, let context):
            print("Type mismatch for type \(type): \(context.debugDescription)")
            print("CodingPath: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
        case .valueNotFound(let type, let context):
            print("Value not found for type \(type): \(context.debugDescription)")
            print("CodingPath: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
        case .keyNotFound(let key, let context):
            print("Key '\(key)' not found: \(context.debugDescription)")
            print("CodingPath: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
        case .dataCorrupted(let context):
            print("Data corrupted: \(context.debugDescription)")
            print("CodingPath: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
        @unknown default:
            print("Unknown decoding error: \(error.localizedDescription)")
        }
    }
}
