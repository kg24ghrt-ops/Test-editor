import Foundation

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
    
    func run(code: String, completion: @escaping (Result<(stdout: String, stderr: String), APIError>) -> Void) {
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
            defer { self?.activeTask = nil }
            
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(.networkError(error)))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(.serverError(statusCode: 0)))
                }
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                    completion(.failure(.serverError(statusCode: httpResponse.statusCode)))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.success((stdout: "", stderr: "")))
                }
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(APIResponsePayload.self, from: data)
                DispatchQueue.main.async {
                    completion(.success((stdout: decodedResponse.stdout, stderr: decodedResponse.stderr)))
                }
            } catch {
                DispatchQueue.main.async {
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
