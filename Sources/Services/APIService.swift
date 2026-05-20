import Foundation

protocol APIServiceDelegate: AnyObject {
    func apiServiceDidReceiveStdout(_ text: String)
    func apiServiceDidReceiveStderr(_ text: String)
    func apiServiceDidReceiveError(_ message: String)
    func apiServiceExecutionDidComplete()
    func apiServiceConnectionStatusChanged(isConnected: Bool)
}

final class APIService: NSObject {
    weak var delegate: APIServiceDelegate?
    
    private var webSocketTask: URLSessionWebSocketTask?
    private let urlSession = URLSession(configuration: .default)
    private let jsonDecoder = JSONDecoder()
    private let jsonEncoder = JSONEncoder()
    private var currentSessionId: String?
    
    private(set) var isConnected = false {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.apiServiceConnectionStatusChanged(isConnected: self.isConnected)
            }
        }
    }
    
    // Data structures mapped directly to your server.py FastAPI frames
    struct WSMessageOut: Encodable {
        let type: String
        let sessionId: String
        let code: String?
        let input: String?
        enum CodingKeys: String, CodingKey {
            case type, code, input
            case sessionId = "session_id"
        }
    }

    struct WSMessageIn: Decodable {
        let type: String
        let sessionId: String?
        let output: String?
        let message: String?
        enum CodingKeys: String, CodingKey {
            case type, output, message
            case sessionId = "session_id"
        }
    }

    func connect() {
        guard webSocketTask == nil else { return }
        guard let url = URL(string: "wss://novacibes-python-running-api.hf.space/ws") else { return }
        
        var request = URLRequest(url: url)
        if let token = TokenManager.shared.getToken() {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        webSocketTask = urlSession.webSocketTask(with: request)
        webSocketTask?.resume()
        isConnected = true
        listen()
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        isConnected = false
    }
    
    func runCode(_ code: String) {
        let sessionId = UUID().uuidString
        self.currentSessionId = sessionId
        let message = WSMessageOut(type: "run", sessionId: sessionId, code: code, input: nil)
        send(message)
    }
    
    func sendStdin(_ input: String) {
        guard let sessionId = currentSessionId else { return }
        let message = WSMessageOut(type: "stdin", sessionId: sessionId, code: nil, input: input)
        send(message)
    }
    
    func stopExecution() {
        guard let sessionId = currentSessionId else { return }
        let message = WSMessageOut(type: "stop", sessionId: sessionId, code: nil, input: nil)
        send(message)
    }
    
    private func send(_ payload: WSMessageOut) {
        guard let task = webSocketTask else { return }
        do {
            let data = try jsonEncoder.encode(payload)
            if let jsonString = String(data: data, encoding: .utf8) {
                task.send(.string(jsonString)) { error in
                    if let error = error { print("WebSocket Send Error: \(error)") }
                }
            }
        } catch { print("Encoding error: \(error)") }
    }
    
    private func listen() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self, self.isConnected else { return }
            switch result {
            case .failure(let error):
                print("WebSocket Connection broken: \(error)")
                self.isConnected = false
            case .success(let message):
                switch message {
                case .string(let text): self.parseMessage(text)
                case .data(let data): if let text = String(data: data, encoding: .utf8) { self.parseMessage(text) }
                @unknown default: break
                }
                self.listen()
            }
        }
    }
    
    private func parseMessage(_ rawString: String) {
        guard let data = rawString.data(using: .utf8) else { return }
        do {
            let incoming = try jsonDecoder.decode(WSMessageIn.self, from: data)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                switch incoming.type {
                case "stdout": if let out = incoming.output { self.delegate?.apiServiceDidReceiveStdout(out) }
                case "stderr": if let err = incoming.output { self.delegate?.apiServiceDidReceiveStderr(err) }
                case "error": if let msg = incoming.message { self.delegate?.apiServiceDidReceiveError(msg) }
                case "done": self.delegate?.apiServiceExecutionDidComplete(); self.currentSessionId = nil
                default: break
                }
            }
        } catch { print("JSON decoding error: \(error)") }
    }
}
