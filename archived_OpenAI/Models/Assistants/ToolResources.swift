//
//  ToolResources.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 8/23/24.
//

struct ToolResources: Codable {
    let codeInterpreter: CodeInterpreterResource?
    let fileSearch: FileSearchResource?
    
    struct FileSearchResource: Codable {
        let vectorStoreIds: [String]
        let vectorStores: [VectorStore]?
        
        struct VectorStore: Codable {
            let fileIds: [String]?
            let chunkingStrategy: ChunkingStrategy?
            let metadata: [String: String]?
            
            struct ChunkingStrategy: Codable {
                let type: ChunkingStrategyType
                let `static`: StaticChunkingStrategy?
                
                enum ChunkingStrategyType: String, Codable {
                    case staticChunkingStrategy = "static"
                    case otherChunkingStrategy = "other"
                }
                
                // Separate structs for each chunking strategy
                struct StaticChunkingStrategy: Codable {
                    let maxChunkSizeTokens: Int
                    let chunkOverlapTokens: Int
                }
                
            }
        }
    }
    
    struct CodeInterpreterResource: Codable {
        let fileIDs: [String]
    }
}
