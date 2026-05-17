import Foundation

enum APIError: Error {
    case missingToken
    case invalidURL
    case networkError(Error)
    case serverError(statusCode: Int)
    case decodingError(Error)
    
    var localizedDescription: String {
        switch self {
        case .missingToken: return "Hugging Face token is missing. Please set your token."
        case .invalidURL: return "The API endpoint URL is invalid."
        case .networkError(let error): return "Network error: \(error.localizedDescription)"
        case .serverError(let code): return "Server returned an error status code: \(code)"
        case .decodingError: return "Failed to process the execution results from the server."
        }
    }
}
