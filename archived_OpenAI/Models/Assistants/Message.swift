//
//  Message.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 8/23/24.
//

import Foundation

struct Message: Codable {
    let id: String
    let object: String // This should always be "thread.message"
    let createdAt: Date
    let threadId: String
    let status: MessageStatus
    let incompleteDetails: IncompleteDetails?
    let completedAt: Date?
    let incompleteAt: Date?
    let role: Role
    let content: [MessageContent]
    let assistantId: String?
    let runId: String?
    let attachments: [Attachment]?
    let metadata: [String: String]?

}

extension Message {
    enum MessageStatus: String, Codable {
        case inProgress = "in_progress"
        case incomplete = "incomplete"
        case completed = "completed"
    }
    
    struct IncompleteDetails: Codable {
        // Add the relevant fields here based on your API's definition of incomplete details
        let reason: String?
    }
    
    
    enum Role: String, Codable {
        case user = "user"
        case assistant = "assistant"
    }
    
    struct MessageContent: Codable {
        let type: MessageType
        let text: TextContent?
        let imageFile: ImageFileContent?
        let imageURL: ImageURLContent?
        let refusal: RefusalContent?

        enum MessageType: String, Codable {
            case text = "text"
            case imageFile = "image_file"
            case imageURL = "image_url"
            case refusal = "refusal"
        }

        struct TextContent: Codable {
            let value: String
            let annotations: [Annotation]?

            struct Annotation: Codable {
                let type: AnnotationType
                let startIndex: Int
                let endIndex: Int

                enum AnnotationType: String, Codable {
                    case fileCitation = "file_citation"
                    case filePath = "file_path"
                }

                struct FileCitation: Codable {
                    let text: String
                    let startIndex: Int
                    let endIndex: Int
                    let fileCitation: FileId
                }

                struct FilePath: Codable {
                    let text: String
                    let startIndex: Int
                    let endIndex: Int
                    let filePath: FileId
                }

                struct FileId: Codable {
                    let fileId: String
                }
            }
        }

        struct ImageFileContent: Codable {
            let fileId: String
            let detail: String?
        }

        struct ImageURLContent: Codable {
            let url: String
            let detail: String?
        }

        struct RefusalContent: Codable {
            let refusal: String
        }
    }


    struct Attachment: Codable {
        var fileID: String?
        var tools: [Tool]?
    }
}
