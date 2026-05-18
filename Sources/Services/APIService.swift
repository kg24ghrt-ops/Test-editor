import Foundation

// ✅ Added @MainActor to handle all state changes (like activeTask) safely on the main thread
@MainActor
final class APIService {
    private let apiURLString = "https://novacibes-python-running-api.hf.space/run"
    private var activeTask: URLSessionDataTask?
    
    struct APIRequestPayload: Encodable {
        let code: String
    }
    
    struct APIResponsePayload: Decodable {
        let stdout: String
        let stderr: String
    }
    
        // ✅ Added @Sendable right before the closure signature definition
    func run(code: String, completion: @escaping @Sendable (Result<(stdout: String, stderr: String), APIError>) -> Void) {
        // Keep your exact same code inside here...
    

        // Cancel any lingering running executions
        cancelRun()
        
        guard let token = TokenManager.shared.getToken() else {
            completion(.failure(.missingToken))
            return
        }
        
        guard let url = URL(string: apiURLString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 600.0 // 10 minutes timeout limit
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let payload = APIRequestPayload(code: code)
        do {
            request.httpBody = try JSONEncoder().encode(payload)
        } catch {
            completion(.failure(.decodingError(error)))
            return
        }
        
        activeTask = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            // ✅ Wrap everything in a MainActor task context to satisfy the Swift 6 compiler
            Task { @MainActor in
                defer { self?.activeTask = nil }
                
                if let error = error {
                    completion(.failure(.networkError(error)))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(.serverError(statusCode: 0)))
                    return
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    completion(.failure(.serverError(statusCode: httpResponse.statusCode)))
                    return
                }
                
                guard let data = data else {
                    completion(.success((stdout: "", stderr: "")))
                    return
                }
                
                do {
                    let decodedResponse = try JSONDecoder().decode(APIResponsePayload.self, from: data)
                    completion(.success((stdout: decodedResponse.stdout, stderr: decodedResponse.stderr)))
                } catch {
                    completion(.failure(.decodingError(error)))
                }
            }
        }
        
        activeTask?.resume()
    }
    
    func cancelRun() {
        activeTask?.cancel()
        activeTask = nil
    }
}
