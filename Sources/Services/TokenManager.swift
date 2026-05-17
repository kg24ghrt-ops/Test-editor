import Foundation
import KeychainSwift

final class TokenManager {
    static let shared = TokenManager()
    private let keychain = KeychainSwift()
    private let tokenKey = "com.novacibes.NovaCibesRunner.hftoken"
    
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
