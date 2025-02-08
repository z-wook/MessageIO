//
//  CryptoManager.swift
//  MessageIO
//
//  Copyright (c) 2025 z-wook. All right reserved.
//

import CryptoKit
import Foundation

final class CryptoManager {
    static let shared = CryptoManager()
    private init() {}
}

extension CryptoManager {
    /// 이메일을 SHA256 해시로 변환하는 메서드
    /// - Parameter email: 해싱할 이메일 문자열
    /// - Returns: SHA256 해시값 (소문자 16진수 문자열)
    func hashEmail(email: String) -> String {
        let data = Data(email.utf8)
        let hashed = SHA256.hash(data: data)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    /// Data -> Curve25519 타입으로 변환시키는 메서드
    /// - Parameter data: 공개키 데이터
    /// - Returns: 공개키
    func convertDataToPublicKey(data: Data) throws -> Curve25519.KeyAgreement.PublicKey {
        try Curve25519.KeyAgreement.PublicKey(rawRepresentation: data)
    }
}

extension CryptoManager {
//    func generateSalt(length: Int = 16) -> Data {
//        var salt = Data(count: length)
//        _ = salt.withUnsafeMutableBytes { buffer in
//            SecRandomCopyBytes(kSecRandomDefault, length, buffer.baseAddress!)
//        }
//        return salt
//    }
    
    /// 그룹키를 생성하는 메서드
    /// - Returns: 그룹키
    func generateGroupKey() -> SymmetricKey {
        return SymmetricKey(size: .bits256)
    }
    
    /// 개인키를 생성하는 메서드
    /// - Returns: 개인키
    /// - Warning: 반드시 키체인으로 저장, 서버에 절대 올리면 안되는 키
    func generatePrivateKey() -> Curve25519.KeyAgreement.PrivateKey {
        let privateKey = Curve25519.KeyAgreement.PrivateKey()
        return privateKey
    }
    
    /// 공개키를 생성하는 메서드
    /// - Parameter privateKey: 개인키
    /// - Returns: 공개키
    func generatePublicKey(privateKey: Curve25519.KeyAgreement.PrivateKey) -> Curve25519.KeyAgreement.PublicKey {
        let publicKey = privateKey.publicKey
        return publicKey
    }
    
    /// 대칭키를 생성하는 메서드
    /// - Parameters:
    ///   - privateKey: 개인키
    ///   - publicKey: 공개키
    /// - Returns: 대칭키
    /// - Note: 대칭키는 그룹키로 사용
    /// - Warning: 서버로 전송 시 암호화 필수
    func generateSymmetricKey(privateKey: Curve25519.KeyAgreement.PrivateKey,
                              publicKey: Curve25519.KeyAgreement.PublicKey) throws -> SymmetricKey {
        do {
            let sharedSecret = try privateKey.sharedSecretFromKeyAgreement(with: publicKey)
            let symmetricKey = sharedSecret.hkdfDerivedSymmetricKey(
                using: SHA256.self,
                salt: "GroupKeySalt".data(using: .utf8)!,
                sharedInfo: Data(),
                outputByteCount: 32
            )
            return symmetricKey
            
        } catch {
            throw error
        }
    }
}

extension CryptoManager {
    /// 그룹키를 암호화하는 메서드
    /// - Parameters:
    ///   - groupKey: 그룹키
    ///   - recipientPublicKey: 수신자 공개키
    ///   - senderPrivateKey: 송신자 개인키
    /// - Returns: 암호화된 그룹키 데이터
    func encryptGroupKey(groupKey: SymmetricKey,
                         recipientPublicKey: Curve25519.KeyAgreement.PublicKey,
                         senderPrivateKey: Curve25519.KeyAgreement.PrivateKey) throws -> Data {
        let sharedSecret = try senderPrivateKey.sharedSecretFromKeyAgreement(with: recipientPublicKey)
        let symmetricKey = sharedSecret.hkdfDerivedSymmetricKey(
            using: SHA256.self,
            salt: "GroupKeySalt".data(using: .utf8)!,
            sharedInfo: Data(),
            outputByteCount: 32
        )
        
        let groupKeyData = groupKey.withUnsafeBytes { Data($0) }
        let sealedBox = try ChaChaPoly.seal(groupKeyData, using: symmetricKey)
        return sealedBox.combined
    }
    
    /// 암호화된 그룹키를 복호화 하는 메서드
    /// - Parameters:
    ///   - encryptedGroupKey: 암호회된 그룹키
    ///   - recipientPrivateKey: 수신자 개인키
    ///   - senderPublicKey: 송신자 공개키
    /// - Returns: 그룹키
    func decryptGroupKey(encryptedGroupKey: Data,
                         recipientPrivateKey: Curve25519.KeyAgreement.PrivateKey,
                         senderPublicKey: Curve25519.KeyAgreement.PublicKey) throws -> SymmetricKey {
        let sharedSecret = try recipientPrivateKey.sharedSecretFromKeyAgreement(with: senderPublicKey)
        let symmetricKey = sharedSecret.hkdfDerivedSymmetricKey(
            using: SHA256.self,
            salt: "GroupKeySalt".data(using: .utf8)!,
            sharedInfo: Data(),
            outputByteCount: 32
        )
        
        let sealedBox = try ChaChaPoly.SealedBox(combined: encryptedGroupKey)
        let decryptedData = try ChaChaPoly.open(sealedBox, using: symmetricKey)
        return SymmetricKey(data: decryptedData)
    }
    
    /// 채팅 메시지를 암호화 하는 메서드
    /// - Parameters:
    ///   - message: 채팅 메시지
    ///   - symmetricKey: 그룹키
    /// - Returns: 암호화된 데이터 + 인증 태그 + Nonce(초기화 벡터)를 포함하는 구조체
    func encryptChatMessage(chatMessage: ChatMessage, symmetricKey: SymmetricKey) throws -> ChaChaPoly.SealedBox {
        let jsonData = try JSONEncoder().encode(chatMessage)
        let encryptedData = try ChaChaPoly.seal(jsonData, using: symmetricKey).combined
        return try ChaChaPoly.SealedBox(combined: encryptedData)
    }
    
    /// 채팅 메시지를 복호화 하는 메서드
    /// - Parameters:
    ///   - sealBox: 암호화된 데이터 + 인증 태그 + Nonce(초기화 벡터)를 포함하는 구조체
    ///   - symmetricKey: 그룹키
    /// - Returns: 채팅 메시지
    func decryptChatMessage(sealBox: ChaChaPoly.SealedBox, symmetricKey: SymmetricKey) throws -> ChatMessage? {
        let decryptedData = try ChaChaPoly.open(sealBox, using: symmetricKey)
        let chatMessage = try JSONDecoder().decode(ChatMessage.self, from: decryptedData)
        return chatMessage
    }
}
