import Foundation
import KeychainSwift

// ✅ Add '@unchecked Sendable' to tell Swift 6 this class is thread-safe
final class TokenManager: @unchecked Sendable {
    static let shared = TokenManager()
    private let keychain = KeychainSwift()
    private let tokenKey = "com.novacibes.NovaCibesRunner.hftoken"
    
    // Rest of your TokenManager code...


    
    private init() {}
    
    func getToken() -> String? {
        return keychain.get(tokenKey)
    }
    
    func save(token: String) {
        keychain.set(token, forKey: tokenKey)
    }
    
    func deleteToken() {
        keychain.delete(tokenKey)
    }
}
