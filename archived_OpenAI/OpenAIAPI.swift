//
//  OpenAI.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 8/19/24.
//

import Foundation

struct OpenAIAPI {
    static let defaultDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }
    
    static let defaultEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .secondsSince1970
        return encoder
    }
    
    static func listAssistants(limit: Int? = 100, order: String? = "desc") async throws -> [Assistant] {
        let listAssistantEndpoint = "https://api.openai.com/v1/assistants"
        var allAssistants: [Assistant] = []
        var hasMore = true
        var after: String? = nil
        
        while hasMore {
            let params = try constructPayload(with: [
                "limit": limit,
                "order": order,
                "after": after
            ])
            let assistantsList = try await NetworkManager.get(urlString: listAssistantEndpoint, headers: headers, queryParams: params)
            let jsonResponse = try parseJSON(from: assistantsList)
            // Ensure "data" key exists and is an array of dictionaries
            guard let assistantsArray = jsonResponse["data"] as? [[String: Any]] else {
                throw OpenAIError.missingDataError(listAssistantEndpoint, "data")
            }
            
            // Attempt to decode each Assistant object
            for assistantData in assistantsArray {
                let assistantData = try JSONSerialization.data(withJSONObject: assistantData)
                let assistant = try defaultDecoder().decode(Assistant.self, from: assistantData)
                allAssistants.append(assistant)
            }
            
            hasMore = jsonResponse["has_more"] as? Bool ?? false
            after = jsonResponse["last_id"] as? String
        }
        
        return allAssistants
    }
    
    static func createAssistant(model: String, name: String, description: String?, tools: [[String: String]]?, instructions: String, responseFormat: ResponseFormat) async throws -> Assistant {
        let createAssistantEndpoint = "https://api.openai.com/v1/assistants"
        
        let requestPayload = try constructPayload(with:[
            "model": model, // You can change the model if needed
            "name": name,
            "instructions": instructions,
            "description": description,
            "tools": tools,
            "response_format": defaultEncoder().encode(responseFormat)
        ])
        
        let response = try await NetworkManager.post(urlString: createAssistantEndpoint, headers: headers, payload: requestPayload)
        
        return try defaultDecoder().decode(Assistant.self, from: response)
    }
    
    static func getAssistant(id: String) async throws -> Assistant {
        let getAssistantEndpoint = "https://api.openai.com/v1/assistants/\(id)"
        let response = try await NetworkManager.get(urlString: getAssistantEndpoint, headers: headers)
        return try defaultDecoder().decode(Assistant.self, from: response)
    }

    static func deleteAssistant(id: String) async throws -> Data {
        let deleteAssistantEndpoint = "https://api.openai.com/v1/assistants/\(id)"
        let response = try await NetworkManager.delete(urlString: deleteAssistantEndpoint, headers: headers)
        return response
    }
    
    static func modifyAssistant(id: String, updates: [String: Any]) async throws -> Assistant {
        let updateEndpoint = "https://api.openai.com/v1/assistants/\(id)"
        
        // Send the update request
        let response = try await NetworkManager.post(urlString: updateEndpoint, headers: headers, payload: updates)
        return try defaultDecoder().decode(Assistant.self, from: response)
    }
    
    static func createThread(messages: [Message]?, toolResources: ToolResources?, metadata: [String: String]?) async throws -> Thread {
        let createThreadEndpoint = "https://api.openai.com/v1/threads"
        
        let requestPayload = try constructPayload(with: [
            "messages": defaultEncoder().encode(messages),
            "tool_resources": defaultEncoder().encode(toolResources),
            "metadata": metadata
        ])
        
        let response = try await NetworkManager.post(urlString: createThreadEndpoint, headers: headers, payload: requestPayload)
        return try defaultDecoder().decode(Thread.self, from: response)
    }
    
    static func modifyThread(id: String, toolResources: ToolResources, metadata: [String: String]?) async throws -> Thread {
        let modifyThreadEndpoint = "https://api.openai.com/v1/threads\(id)"
        
        let requestPayload = try constructPayload(with: [
            "tool_resources": defaultEncoder().encode(toolResources),
            "metadata": metadata
        ])
        
        let response = try await NetworkManager.post(urlString: modifyThreadEndpoint, headers: headers, payload: requestPayload)
        return try defaultDecoder().decode(Thread.self, from: response)
    }
    
    static func createMessage(threadId: String, role: Message.Role, content: Message.MessageContent, attachments: Message.Attachment?, metadata: [String: String]?) async throws -> Message {
        let createMessageEndpoint = "https://api.openai.com/v1/threads\(threadId)/messages"
        
        let requestPayload = try constructPayload(with: [
            "role": defaultEncoder().encode(role),
            "content": defaultEncoder().encode(content),
            "attachments": defaultEncoder().encode(attachments),
            "metadata": metadata
        ])
        
        let response = try await NetworkManager.post(urlString: createMessageEndpoint, headers: headers, payload: requestPayload)
        return try defaultDecoder().decode(Message.self, from: response)
        
    }
    
    static func createRun(threadId: String, assistantId: String, model: String?, instructions: String? , additional_instructions: String?, additional_messages: [Message]?, stream: Bool?, responseFormat: ResponseFormat) async throws -> Run {
        let createRunEndpoint = "https://api.openai.com/v1/threads\(threadId)/runs"
        
        let requestPayload = try constructPayload(with: [
            "assistant_id": assistantId,
            "model": model,
            "instructions": instructions,
            "additional_instructions": additional_instructions,
            "additional_messages": defaultEncoder().encode(additional_messages),
            "stream": stream,
            "response_format": defaultEncoder().encode(responseFormat)
        ])
        
        let response = try await NetworkManager.post(urlString: createRunEndpoint, headers: headers, payload: requestPayload)
        return try defaultDecoder().decode(Run.self, from: response)
    }

}

extension OpenAIAPI {
    private static let apiKey = OpenAIAPIConfig.apiKey
    
    private static var headers: [String: String] {
        return [
            "Authorization": "Bearer \(apiKey)",
            "Content-type": "application/json",
            "OpenAI-Beta": "assistants=v2"
        ]
    }
    
    enum OpenAIError: LocalizedError {
        case invalidResponseFormat
        case jsonParsingError(Error)
        case payloadConstructionError(Error)
        case missingDataError(String, String)
        case other(Error)
        
        var errrorDescription: String? {
            switch self {
            case .invalidResponseFormat:
                return "Could not convert API response to JSON."
            case .jsonParsingError(let error):
                return "JSON parsing error: \(error.localizedDescription)"
            case .payloadConstructionError(let error):
                return "Error constructing the payload: \(error.localizedDescription)"
            case .missingDataError(let endpoint, let key):
                return "Missing key: \(key) in API call to: \(endpoint)."
            case .other(let error):
                return "An unexpected error occurred: \(error.localizedDescription)"
            }
        }
    }
    
    private static func parseJSON(from data: Data) throws -> [String: Any] {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            return json ?? [:] // Return an empty dictionary if the cast fails
        } catch {
            throw OpenAIError.jsonParsingError(error)
        }
    }
    
    // Function to safely construct the payload
    private static func constructPayload(with parameters: [String: Any?]) throws -> [String: Any] {
        var payload = [String: Any]()
        for (key, value) in parameters {
            if let value = value {
                if let dataValue = value as? Data {
                    payload[key] = try JSONSerialization.jsonObject(with: dataValue)
                } else {
                    payload[key] = value
                }
            }
        }
        return payload
    }
    
    struct OpenAIAPIConfig {
        static var apiKey: String {
            guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "OpenAI_API_Key") as? String else {
                fatalError("API Key not found in Info.plist")
            }
            return apiKey
        }
    }
}



// Optional implemention using dependency injection, and a singleton to maintain a consistent state for thread across different instantiations


//class OpenAI {
//    static let shared = OpenAI()
//
//    private let networkManager: NetworkManaging
//    private let config: Configuring
//    private var currentThread: String?
//
//    init(networkManager: NetworkManaging = NetworkManager(), config: Configuring = DefaultConfig(apiKey: "your-api-key")) {
//        self.networkManager = networkManager
//        self.config = config
//    }
//
//    func setThread(_ thread: String) {
//        self.currentThread = thread
//    }
//
//    func getThread() -> String? {
//        return currentThread
//    }
//
//    func sendMessage(message: String) async throws -> [String: Any] {
//        guard let thread = currentThread else {
//            throw OpenAIError.noThreadSelected
//        }
//        let endpoint = "https://api.openai.com/v1/threads/\(thread)/messages"
//        let payload = ["message": message]
//        let response = try await networkManager.post(urlString: endpoint, headers: headers, payload: payload)
//        return try parseJSON(from: response)
//    }
//
//    private var headers: [String: String] {
//        return ["Authorization": "Bearer \(config.apiKey)"]
//    }
//
//    private func parseJSON(from response: String) throws -> [String: Any] {
//        guard let jsonData = response.data(using: .utf8) else {
//            throw OpenAIError.invalidResponseFormat
//        }
//        do {
//            let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
//            return json ?? [:]
//        } catch {
//            throw OpenAIError.jsonParsingError(error)
//        }
//    }
//
//    enum OpenAIError: Error {
//        case noThreadSelected
//        case invalidResponseFormat
//        case jsonParsingError(Error)
//    }
//}
