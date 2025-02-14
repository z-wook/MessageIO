//
//  MainChatVM.swift
//  MessageIO
//
//  Copyright (c) 2025 z-wook. All right reserved.
//

import Combine
import CryptoKit
import Foundation
import FirebaseFirestore

final class MainChatVM {
    private let cryptoManager = CryptoManager.shared
    private let keyChainManager = KeyChainManager.shared
    private let firestoreManager = FirestoreManager.shared
    private let keyChainKeyLabel = "PRIVATE_KEY"
    @Published private(set) var chatRoomSummarys: [ChatRoomSummary] = []
    private var listener: [String: ListenerRegistration?] = [:]
    
    deinit {
        listener.forEach {
            $0.value?.remove()
        }
    }
}

extension MainChatVM {
    func loadInitialMessages() async {
        guard let myPrivateKey = keyChainManager.loadPrivateKey(keyLabel: keyChainKeyLabel) else { return }
        
        do {
            let roomIDs = try await firestoreManager.loadParticipatingRooms()
            let fetchedMessages = try await fetchMessages(from: roomIDs, myPrivateKey: myPrivateKey)
            await updateChatRoomSummarys(chatRoomSummarys: fetchedMessages)     // 메인 스레드에서 실행
            
        } catch {
            print("❌ 전체 채팅 메시지를 가져오는 중 오류 발생: \(error)")
        }
    }
    
    func getUserID(email: String) async -> String? {
        do {
            let userID = try await firestoreManager.loadUserID(email: email)
            return userID
        } catch {
            print("❌ \(error)")
            return nil
        }
    }
}

private extension MainChatVM {
    func observeChatMessages(roomID: String, groupKey: SymmetricKey) {
        firestoreManager.observeLatestMessage(roomID: roomID, symmetricKey: groupKey) { [weak self] listener, newMessages in
            if self?.listener[roomID] == nil {
                self?.listener[roomID] = listener
            }
            
            Task {
                await self?.updateNewMessage(roomID: roomID, newMessage: newMessages.first)
            }
        }
    }
    
    func fetchMessages(from roomIDs: [String], myPrivateKey: Curve25519.KeyAgreement.PrivateKey) async throws -> [ChatRoomSummary] {
        guard let myPrivateKey = keyChainManager.loadPrivateKey(keyLabel: keyChainKeyLabel) else { return [] }
        let firestoreManager = self.firestoreManager
        let cryptoManager = self.cryptoManager
        var fetchedChatRoomSummary: [ChatRoomSummary] = []
        
        try await withThrowingTaskGroup(of: ChatRoomSummary?.self) { [weak self] group in
            for roomID in roomIDs {
                group.addTask {
                    do {
                        // 참가자 조회
                        let participats = try await firestoreManager.loadParticipats(roomID: roomID)
                        
                        // 암호화된 그룹키 조회
                        let encryptedGroupKey = try await firestoreManager.loadEncryptedGroupKey(roomID: roomID)
                        
                        // 송신자 공개키 데이터 조회
                        guard let senderPublicKeyData = try await firestoreManager.loadPublicKeyData(userID: encryptedGroupKey.senderID) else {
                            print("❌ \(roomID)에서 공개키 데이터를 가져오지 못했습니다.")
                            return nil
                        }
                        
                        // 송신자 공개키 데이터 변환
                        let senderPublicKey = try cryptoManager.convertDataToPublicKey(data: senderPublicKeyData)
                        
                        // 그룹키 복호화
                        let groupKey = try cryptoManager.decryptGroupKey(encryptedGroupKey: encryptedGroupKey.key,
                                                                         recipientPrivateKey: myPrivateKey,
                                                                         senderPublicKey: senderPublicKey)
                        
                        // Todo 옵저버 추가
                        self?.observeChatMessages(roomID: roomID, groupKey: groupKey)
                        
                        // 채팅 메시지 조회
                        let (_, chatMessages) = try await firestoreManager.loadChatMessages(roomID: roomID,
                                                                                            symmetricKey: groupKey,
                                                                                            requestCount: 1)
                        
                        return ChatRoomSummary(id: roomID, groupKey: groupKey, participantsID: participats, lastMessage: chatMessages.first)
                        
                    } catch {
                        print("❌ \(roomID)에서 메시지를 가져오는 중 오류 발생: \(error)")
                        return nil
                    }
                }
            }
            
            for try await chatRoomSummary in group {
                if let chatRoomSummary = chatRoomSummary {
                    fetchedChatRoomSummary.append(chatRoomSummary)
                }
            }
        }
        
        fetchedChatRoomSummary.sort {
            $0.lastMessage?.timestamp ?? Date() > $1.lastMessage?.timestamp ?? Date()
        }
        return fetchedChatRoomSummary
    }
    
    @MainActor
    func updateChatRoomSummarys(chatRoomSummarys: [ChatRoomSummary]) {
        self.chatRoomSummarys = chatRoomSummarys
    }
    
    @MainActor
    func updateNewMessage(roomID: String, newMessage: ChatMessage?) {
        if let index = chatRoomSummarys.firstIndex(where: { $0.id == roomID }) {
            chatRoomSummarys[index].lastMessage = newMessage
        }
    }
}
