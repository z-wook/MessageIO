//
//  FirestoreManager.swift
//  MessageIO
//
//  Copyright (c) 2025 z-wook. All right reserved.
//

import CryptoKit
import FirebaseCore
import FirebaseFirestore
import Foundation

enum FirebaseError: String, Error {
    case noUserData
    case noEmail
}

final class FirestoreManager {
    static let shared = FirestoreManager()
    private let storeDB = Firestore.firestore()
    private var listener: ListenerRegistration?
    private init() {}
    
    enum CollectionPath: String {
        case roomID
        case encodedPublicKey
        case hashEmail
        case messages
        case user
        
        var path: String {
            return self.rawValue
        }
    }
}

struct EncodedPublicKey: Codable {
    let key: String
}

struct EncryptedGroupKey: Codable {
    let senderID: String
    let key: Data
}

struct UserIDInfo: Codable {
    let id: String
}

struct ParticipatingRoom: Codable {
    let roomIDs: [String]
}

extension FirestoreManager {
    func saveMyID() throws {
        guard let user = AuthManager.shared.loadCurrentUserData(),
              let email = user.email else { throw FirebaseError.noEmail }
        let hashEmail = CryptoManager.shared.hashEmail(email: email)
        let myUIDInfo = UserIDInfo(id: user.uid)
        try storeDB.collection(CollectionPath.hashEmail.path).document(hashEmail)
            .setData(from: myUIDInfo)
    }
    
    func loadUserID(email: String) async throws -> String {
        let hashEmail = CryptoManager.shared.hashEmail(email: email)
        let userUIDInfo = try await storeDB.collection(CollectionPath.hashEmail.path).document(hashEmail)
            .getDocument(as: UserIDInfo.self)
        return userUIDInfo.id
    }
    
    /// 소속된 채팅방을 추가하는 메서드
    /// - Parameters:
    ///   - invitationUserID: 초대 대상의 ID
    ///   - newRoomID: 추가 할 채팅방 ID
    func saveParticipatingRoom(invitationUserID: String, newRoomID: String) async throws {
        let userDocRef = storeDB.collection(CollectionPath.user.path).document(invitationUserID)
        
        do {
            try await userDocRef.updateData([
                "roomIDs": FieldValue.arrayUnion([newRoomID])
            ])
        } catch {
            // 문서가 없으면 새로 생성
            let participatingRoom = ParticipatingRoom(roomIDs: [newRoomID])
            try userDocRef.setData(from: participatingRoom)
        }
    }
    
    /// 참가하고 있는 채팅방 ID를
    /// - Returns: 참가방 ID 리스트
    func loadParticipatingRooms() async throws -> [String] {
        guard let user = AuthManager.shared.loadCurrentUserData() else {
            throw FirebaseError.noUserData
        }
        let userDocRef = storeDB.collection(CollectionPath.user.path).document(user.uid)
        let participatingRoom = try await userDocRef.getDocument(as: ParticipatingRoom.self)
        return participatingRoom.roomIDs
    }
    
    func loadParticipats(roomID: String) async throws -> [String] {
        let userDocRef = storeDB.collection(CollectionPath.roomID.path).document(roomID)
            .collection(CollectionPath.user.path)
        let snapshots = try await userDocRef.getDocuments().documents
        
        let participats = snapshots.compactMap { snapshot in
            return snapshot.documentID
        }
        return participats
    }
    
    /// 소속된 채팅방을 삭제하는 메서드
    /// - Parameters:
    ///   - userID: 삭제 대상의 ID
    ///   - roomID: 삭제할 채팅방 ID
    func removeParticipatingRoom(userID: String, roomID: String) async throws {
        let userDocRef = storeDB.collection(CollectionPath.user.path).document(userID)
        
        do {
            try await userDocRef.updateData([
                "roomIDs": FieldValue.arrayRemove([roomID])
            ])
            print("✅ 채팅방 삭제 성공: \(roomID)")
        } catch {
            print("❌ 채팅방 삭제 실패: \(error)")
            throw error
        }
    }
}

extension FirestoreManager {
    func saveEncryptedGroupKey(roomID: String, recipientID: String, encryptedGroupKey: EncryptedGroupKey) throws {
        try storeDB.collection(CollectionPath.roomID.path).document(roomID)
            .collection(CollectionPath.user.path).document(recipientID)
            .setData(from: encryptedGroupKey)
    }
    
    func loadEncryptedGroupKey(roomID: String) async throws -> EncryptedGroupKey {
        guard let user = AuthManager.shared.loadCurrentUserData() else { throw FirebaseError.noUserData }
        let encryptedGroupKey = try await storeDB.collection(CollectionPath.roomID.path).document(roomID)
            .collection(CollectionPath.user.path).document(user.uid)
            .getDocument(as: EncryptedGroupKey.self)
        return encryptedGroupKey
    }
    
    func savePublickey(encodedPublickey: EncodedPublicKey) throws {
        guard let user = AuthManager.shared.loadCurrentUserData() else { throw FirebaseError.noUserData }
        try storeDB.collection(CollectionPath.encodedPublicKey.path).document(user.uid)
            .setData(from: encodedPublickey)
    }
    
    /// 공개키를 조회하는 메서드
    /// - Parameter userID: 조회하려는 유저의 ID
    /// - Returns: 공개키 데이터
    func loadPublicKeyData(userID: String) async throws -> Data? {
        let snapshot = try await storeDB.collection(CollectionPath.encodedPublicKey.path).document(userID).getDocument()
        guard snapshot.exists else { return nil }
        let encodedPublicKey = try snapshot.data(as: EncodedPublicKey.self)
        let publicKeyData = Data(base64Encoded: encodedPublicKey.key)
        return publicKeyData
    }
}

extension FirestoreManager {
    func saveChatMessageData(roomID: String, messageID: String, sealBox: ChaChaPoly.SealedBox) throws {
        let encryptedData = sealBox.combined.base64EncodedString()
        let encryptedMessageData = EncryptedMessageData(data: encryptedData, timeStamp: Date())
        
        try storeDB.collection(CollectionPath.roomID.path).document(roomID)
            .collection(CollectionPath.messages.path).document(messageID)
            .setData(from: encryptedMessageData)
    }
    
    /// 채팅 메시지를 조회하는 메서드
    /// - Parameters:
    ///   - roomID: 채팅방 ID
    ///   - symmetricKey: 공개키
    ///   - lastDocumentSnapshot: 다음 로드를 위한 마지막 문서
    ///   - requestCount: 메시지 요청 개수
    /// - Returns: (마지막 문서, 메시지 리스트)
    /// - Note: requestCount = 1로 하면 가장 최신 메시지 조회 가능
    func loadChatMessages(roomID: String, symmetricKey: SymmetricKey, lastDocumentSnapshot: DocumentSnapshot? = nil,
                          requestCount: Int = 50) async throws -> (DocumentSnapshot?, [ChatMessage]) {
        var query = storeDB.collection(CollectionPath.roomID.path).document(roomID)
            .collection(CollectionPath.messages.path)
            .order(by: "timeStamp", descending: true)   // timeStamp기준 내림차순
            .limit(to: requestCount)
        
        if let lastSnapshot = lastDocumentSnapshot {
            query = query.start(afterDocument: lastSnapshot) // 마지막 문서 이후 데이터 가져오기
        }
        
        let documentSnapshots = try await query.getDocuments().documents
        
        // 새롭게 가져온 문서 중 마지막 문서 저장 (다음 로드를 위해)
        let newLastDocumentSnapshot = documentSnapshots.last
        
        let chatMessages: [ChatMessage] = documentSnapshots.compactMap { snapshot in
            decryptMessage(snapshot: snapshot, symmetricKey: symmetricKey)
        }
        
        return (newLastDocumentSnapshot, chatMessages)
    }
    
    /// 실시간으로 채팅 메시지를 감지하여 업데이트하는 메서드
    /// - Parameters:
    ///   - roomID: 채팅방 ID
    ///   - symmetricKey: 공개키
    ///   - onUpdate: 새로운 메시지가 감지될 때 호출되는 콜백
    func observeNewMessages(roomID: String, symmetricKey: SymmetricKey, onUpdate: @escaping ([ChatMessage]) -> Void) {
        removeListener()
        
        listener = storeDB.collection(CollectionPath.roomID.path).document(roomID)
            .collection(CollectionPath.messages.path)
            .order(by: "timeStamp", descending: true)
            .limit(to: 1)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("❌ 실시간 메시지 로드 오류: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                let newMessages: [ChatMessage] = documents.compactMap { [weak self] document in
                    self?.decryptMessage(snapshot: document, symmetricKey: symmetricKey)
                }
                
                onUpdate(newMessages)
            }
    }
    
    /// 기존 리스너 제거(중복 방지)
    func removeListener() {
        listener?.remove()
        listener = nil
    }
}

private extension FirestoreManager {
    func decryptMessage(snapshot: QueryDocumentSnapshot, symmetricKey: SymmetricKey) -> ChatMessage? {
        do {
            let encryptedMessageData = try snapshot.data(as: EncryptedMessageData.self)
            guard let encryptedData = Data(base64Encoded: encryptedMessageData.data),
                  let sealedBox = try? ChaChaPoly.SealedBox(combined: encryptedData) else {
                print("❌ Base64 디코딩 또는 SealedBox 생성 실패")
                return nil
            }
            
            return try CryptoManager.shared.decryptChatMessage(sealBox: sealedBox, symmetricKey: symmetricKey)
        } catch {
            print("❌ 복호화 실패: \(error.localizedDescription)")
            return nil
        }
    }
}
