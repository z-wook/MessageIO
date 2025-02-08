//
//  KeyChainManager.swift
//  MessageIO
//
//  Copyright (c) 2025 z-wook. All right reserved.
//

import CryptoKit
import Foundation
import Security

final class KeyChainManager {
    static let shared = KeyChainManager()
    private init() {}
}

extension KeyChainManager {
    /// 키체인에 개인키를 저장하는 메서드
    /// - Parameters:
    ///   - privateKey: 개인키
    ///   - keyLabel: 키를 찾을 때 사용할 태그
    /// - Returns: 저장 성공여부
    func savePrivateKey(privateKey: Curve25519.KeyAgreement.PrivateKey, keyLabel: String) -> Bool {
        let tag = keyLabel.data(using: .utf8)!
        let keyData = privateKey.rawRepresentation
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,                              // 암호화 키 항목을 저장할 때 사용
            kSecAttrApplicationTag as String: tag,                          // 키를 찾을 때 사용할 태그
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,     // Curve25519 또는 P-256 키 타입
            kSecValueData as String: keyData,                               // 개인키 데이터
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked    // 기기가 잠금 해제 상태일 때만 접근 가능 (보안 강화)
        ]
        
        // 기존 키 삭제 후 저장 (덮어쓰기)
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    /// 키체인에서 개인키 불러오는 메서드
    /// - Parameter keyLabel: 찾는 태그
    /// - Returns: 개인키
    func loadPrivateKey(keyLabel: String) -> Curve25519.KeyAgreement.PrivateKey? {
        let tag = keyLabel.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag,
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecReturnData as String: kCFBooleanTrue as Any // 키 데이터를 반환하도록 설정
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let keyData = result as? Data else {
            return nil // 키가 없거나 가져오는데 실패한 경우
        }
        return try? Curve25519.KeyAgreement.PrivateKey(rawRepresentation: keyData)
    }
    
    /// 키체인에서 개인키를 삭제하는 메서드
    /// - Parameter keyLabel: 삭제할 태그
    /// - Returns: 삭제 여부
    /// - Warning: KeyChain에서 삭제하는 메서드
    func deletePrivateKey(keyLabel: String) -> Bool {
        let tag = keyLabel.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag
        ]
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
}
