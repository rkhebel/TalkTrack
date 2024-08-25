//
//  VectorStore.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 8/23/24.
//

import Foundation

struct VectorStore: Codable {
    let id: String
    let object: String
    let createdAt: Date
    let name: String
    let usageBytes: Int
    let fileCounts: FileCounts
    let status: VectorStoreStatus
    let expiresAfter: ExpiresAfter?
    let expiresAt: Date?
    let lastActiveAt: Date?
    let metadata: [String: String]

    // Nested struct for file counts
    struct FileCounts: Codable {
        let inProgress: Int
        let completed: Int
        let failed: Int
        let cancelled: Int
        let total: Int
    }

    // Enum for vector store status
    enum VectorStoreStatus: String, Codable {
        case expired = "expired"
        case inProgress = "in_progress"
        case completed = "completed"
    }

    // Nested struct for expiration policy
    struct ExpiresAfter: Codable {
        let anchor: AnchorType
        let days: Int

        enum AnchorType: String, Codable {
            case lastActiveAt = "last_active_at"
        }
    }
}

