//
//  VectorStoreFile.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 8/23/24.
//

import Foundation

struct VectorStoreFile: Codable {
    let id: String
    let object: String
    let usageBytes: Int
    let createdAt: Date
    let vectorStoreId: String
    let status: FileStatus
    let lastError: LastError?
    let chunkingStrategy: ChunkingStrategy

    // Enum for file status
    enum FileStatus: String, Codable {
        case inProgress = "in_progress"
        case completed = "completed"
        case cancelled = "cancelled"
        case failed = "failed"
    }

    // Nested struct for last error
    struct LastError: Codable {
        let code: ErrorCode
        let message: String
        
        enum ErrorCode: String, Codable {
            case serverError = "server_error"
            case rateLimitExceeded = "rate_limit_exceeded"
        }
    }
    
    struct ChunkingStrategy: Codable {
        let type: ChunkingStrategyType
        let `static`: StaticChunkingStrategy?
        
        enum ChunkingStrategyType: String, Codable {
            case staticChunkingStrategy = "static"
            case otherChunkingStrategy = "other"
        }
        
    }

    // Separate structs for each chunking strategy
    struct StaticChunkingStrategy: Codable {
        let maxChunkSizeTokens: Int
        let chunkOverlapTokens: Int
    }

}

