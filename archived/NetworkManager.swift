//
//  NetworkRequestHelper.swift
//  TalkTrack
//
//  Created by Ryan Hebel on 8/20/24.
//
import Foundation

struct NetworkManager {
    // Simplified and Enhanced Post Request Function with Throwing Errors
    static func post(urlString: String, headers: [String: String]?, payload: [String: Any]) async throws -> Data {
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Set additional headers if provided
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
            request.httpBody = jsonData
        } catch {
            throw NetworkError.serializationError(error)
        }
        
        let responseData = try await performRequest(request: request)
        return responseData

    }

    // Simplified and Enhanced Get Request Function with Throwing Errors
    static func get(urlString: String, headers: [String: String]?, queryParams: [String: Any]? = nil) async throws -> Data {
        var urlComponents = URLComponents(string: urlString)
        
        if let queryParams = queryParams {
            urlComponents?.queryItems = queryParams.map { key, value in
                URLQueryItem(name: key, value: "\(value)")
            }
        }
        
        guard let url = urlComponents?.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Set additional headers if provided
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        let responseData = try await performRequest(request: request)
        return responseData
    }
    
    static func delete(urlString: String, headers: [String: String]?) async throws -> Data {
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        // Set additional headers if provided
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        let responseData = try await performRequest(request: request)
        return responseData
        
    }

}

extension NetworkManager {
    // Custom Error Type for More Granular Error Handling
    enum NetworkError: LocalizedError {
        case invalidURL
        case noData
        case invalidResponse
        case httpError(statusCode: Int, description: String, body: String)
        case serializationError(Error)
        case streamError(Error)
        case other(Error)
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "The URL provided was invalid."
            case .noData:
                return "No data was returned by the request."
            case .invalidResponse:
                return "The response received from the server was invalid."
            case .httpError(let statusCode, let description, let body):
                return "HTTP Error: \(statusCode) - \(description) - \(body)"
            case .serializationError(let error):
                return "Serialization Error: \(error.localizedDescription)"
            case .streamError(let error):
                return "Streaming Error: \(error.localizedDescription)"
            case .other(let error):
                return "An unexpected error occurred: \(error.localizedDescription)"
            }
        }
    }
    
    static private func performRequest(request: URLRequest) async throws -> Data {
        // Perform the request and unwrap the response
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw NetworkError.other(error) // Wrap and throw as NetworkError.other
        }

        // Validate the response as an HTTPURLResponse
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        // Check for a valid HTTP status code
        guard (200...299).contains(httpResponse.statusCode) else {
            let description = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
            let body = String(data: data, encoding: .utf8)
            throw NetworkError.httpError(statusCode: httpResponse.statusCode, description: description, body: body ?? "Could not read body.")
        }

        // Decode the response data to a string
        guard !data.isEmpty else {
            throw NetworkError.noData
        }

        return data
    }
}
