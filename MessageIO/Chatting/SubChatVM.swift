//
//  SubChatVM.swift
//  MessageIO
//
//  Copyright (c) 2024 z-wook. All right reserved.
//

import Combine
import CryptoKit
import FirebaseFirestore
import Foundation

final class SubChatVM {
    enum ChatCellType {
        case left
        case right
    }
    enum KeyboardState {
        case show
        case hide
    }
    
    enum ErrorType: String, Error {
        case noUserData
        case noGroupKey
        case noPublicKeyData
        case noPrivateKey
    }
    
    enum FetchState {
        case initialLoad
        case loadMore
        case nomal
        case send
    }
    
    let authManager = AuthManager.shared
    private let cryptoManager = CryptoManager.shared
    private let firestoreManager = FirestoreManager.shared
    private let keyChainManager = KeyChainManager.shared
    
    private(set) var chatRoom: ChatRoom
    @Published private(set) var chatMessages: [ChatMessage] = []
    private(set) var lastSnapshot: DocumentSnapshot?    // 채팅 페이징을 위한 Snapshot
    private let keyChainKeyLabel = "PRIVATE_KEY"
    var isKeyboardVisible: Bool?    // 키보드 상태
    var isFetching: Bool = false
    private let requestCount = 50
    
    var fetchState: FetchState = .initialLoad
    
    init(chatRoom: ChatRoom) {
        self.chatRoom = chatRoom
    }
}

extension SubChatVM {
    func loadInitialMessages() async {
        guard let groupKey = chatRoom.groupKey else {
            print("❌ 그룹키가 없습니다.")
            return
        }
        
        do {
            observeChatMessages()
            let (documentSnapshot, chatMessagges) = try await firestoreManager
                .loadChatMessages(roomID: chatRoom.id,
                                  symmetricKey: groupKey,
                                  lastDocumentSnapshot: lastSnapshot,
                                  requestCount: requestCount)
            
            await fetchChatMessage(messages: chatMessagges, documentSnapshot: documentSnapshot)
            
        } catch {
            print("❌ 메시지 로드 실패: \(error)")
        }
    }
    
    func loadMoreMessages() async {
        guard let lastSnapshot = lastSnapshot, let groupKey = chatRoom.groupKey else { return }
        
        do {
            let (newLastSnapshot, messages) = try await firestoreManager
                .loadChatMessages(roomID: chatRoom.id,
                                  symmetricKey: groupKey,
                                  lastDocumentSnapshot: lastSnapshot,
                                  requestCount: requestCount)
            
            await insertMessages(messages: messages, newLastSnapshot: newLastSnapshot)
            
        } catch {
            print("❌ 추가 메시지 로드 실패: \(error)")
            fetchState = .nomal
        }
    }
    
    func sendMessageProcess(chatMessage: ChatMessage) async {
        // TODO: - 메시지 보낼 때 상대방이 채팅방에 있는지 확인부터 해야함 (채팅방에 나 혼자인지 확인)
        do {
            // 새로운 방이라면 그룹키 생성
            if chatRoom.groupKey == nil {
                chatRoom.groupKey = cryptoManager.generateGroupKey()
                
                guard let groupKey = chatRoom.groupKey else {
                    print("❌ 그룹키 생성 실패")
                    return
                }
                
                // 그룹키를 참가자들에게 공유
                try await withThrowingTaskGroup(of: Void.self) { group in
                    for userID in chatRoom.participantsID {
                        group.addTask {
                            try await self.sendGroupKeyToServer(recipientID: userID, groupKey: groupKey, roomID: self.chatRoom.id)
                        }
                        group.addTask {
                            try await self.inviteChatingRoom(invitationUserID: userID, roomID: self.chatRoom.id)
                        }
                    }
                    try await group.waitForAll()
                }
            }
            
            guard let groupKey = chatRoom.groupKey else {
                print("❌ 그룹키가 없습니다.")
                return
            }
            
            try sendChatData(roomID: chatRoom.id, chatMessage: chatMessage, groupKey: groupKey)
            
        } catch {
            print("❌ 메시지 전송 실패: \(error)")
        }
    }
}

extension SubChatVM {
    /// 채팅 길이에 따라 ChatCell의 높이를 계산하는 메서드
    /// - Parameters:
    ///   - chatCellType: 좌/우 CellType
    ///   - text: 채팅 text 데이터
    ///   - cellWidth: Cell 넓이
    ///   - lblMaxWidth: 채팅 라벨의 최대 길이
    /// - Returns: CGSize(Cell 넓이, Cell 높이)
    func getEstimatedChatCellSize(chatCellType: ChatCellType,
                                  text: String,
                                  cellWidth: CGFloat,
                                  lblMaxWidth: CGFloat) -> CGSize {
        let attributes: [NSAttributedString.Key: Any] = [.font: ThemeFont.regular16Font]
        
        // messageBoxView의 top, bottom inset
        let messageBoxViewInsets = AppConstraint.size8 * 2
        
        // chattingLabel의 top, bottom inset
        let chatLabelInsets = AppConstraint.size8 * 2
        
        // chattingVStackView의 spacing
        let chatVStackSpacing = AppConstraint.size10
        
        let baseHeight: CGFloat = chatCellType == .left ? AppConstraint.size20 : 0
        let constraintWidth = lblMaxWidth - (AppConstraint.size14 + AppConstraint.size8)
        let constraintSize = CGSize(width: constraintWidth, height: .greatestFiniteMagnitude)
        let boundingBox = text.boundingRect(
            with: constraintSize,
            options: .usesLineFragmentOrigin,
            attributes: attributes,
            context: nil
        )
        let estimatedHeight = baseHeight + ceil(boundingBox.height) + messageBoxViewInsets
        + chatLabelInsets + (chatCellType == .left ? chatVStackSpacing : 0)
        
        return CGSize(width: cellWidth, height: estimatedHeight)
    }
    
    /// 공백 체크를 하는 메서드
    /// - Parameter text: 공백 체크를 할 문자열
    /// - Returns: 공백 여부
    func isOnlyWhitespace(text: String) -> Bool {
        return text.range(of: "^[\\s]*$", options: .regularExpression) != nil
    }
}

private extension SubChatVM {
    func sendChatData(roomID: String, chatMessage: ChatMessage, groupKey: SymmetricKey) throws {
        let sealBox = try cryptoManager.encryptChatMessage(chatMessage: chatMessage, symmetricKey: groupKey)
        try firestoreManager.saveChatMessageData(roomID: roomID, messageID: chatMessage.id, sealBox: sealBox)
    }
    
    func observeChatMessages() {
        guard let groupKey = chatRoom.groupKey else {
            print("❌ 그룹키가 없습니다.")
            return
        }
        
        firestoreManager.observeChatRoomMessages(roomID: chatRoom.id, symmetricKey: groupKey) { [weak self] newMessages in
            if self?.lastSnapshot == nil && self?.chatMessages.isEmpty == true {
                return
            }
            
            Task { @MainActor in
                self?.appendMessages(newMessages: newMessages)
            }
        }
    }
    
    func sendGroupKeyToServer(recipientID: String, groupKey: SymmetricKey, roomID: String) async throws {
        guard let recipientPublicKeyData = try await firestoreManager.loadPublicKeyData(userID: recipientID) else {
            throw ErrorType.noPublicKeyData
        }
        guard let senderPrivateKey = keyChainManager.loadPrivateKey(keyLabel: keyChainKeyLabel) else {
            throw ErrorType.noPrivateKey
        }
        guard let userData = authManager.loadCurrentUserData() else {
            throw ErrorType.noUserData
        }
        
        let recipientPublicKey = try cryptoManager.convertDataToPublicKey(data: recipientPublicKeyData)
        let encryptedGroupKeyData = try cryptoManager.encryptGroupKey(
            groupKey: groupKey,
            recipientPublicKey: recipientPublicKey,
            senderPrivateKey: senderPrivateKey
        )
        let encryptedGroupKey = EncryptedGroupKey(senderID: userData.uid, key: encryptedGroupKeyData)
        try firestoreManager.saveEncryptedGroupKey(roomID: roomID, recipientID: recipientID, encryptedGroupKey: encryptedGroupKey)
    }
    
    func inviteChatingRoom(invitationUserID: String, roomID: String) async throws {
        try await firestoreManager.saveParticipatingRoom(invitationUserID: invitationUserID, newRoomID: roomID)
    }
    
    @MainActor
    func fetchChatMessage(messages: [ChatMessage], documentSnapshot: DocumentSnapshot?) {
        chatMessages = messages.reversed()
        lastSnapshot = documentSnapshot
    }
    
    /// 실시간 메시지 수신 시 메시지 업데이트를 위햔 메서드
    /// - Parameter newMessages: 새로운 메시지
    @MainActor
    func appendMessages(newMessages: [ChatMessage]) {
        chatMessages.append(contentsOf: newMessages)
    }
    
    @MainActor
    func insertMessages(messages: [ChatMessage], newLastSnapshot: DocumentSnapshot?) {
        chatMessages.insert(contentsOf: messages.reversed(), at: 0) // 위로 추가
        lastSnapshot = newLastSnapshot
    }
    
    /// 현재는 사용하지 않는 메서드
    @MainActor
    func rollbackMessage(chatMessage: ChatMessage) {
        if let index = self.chatMessages.firstIndex(where: { $0.id == chatMessage.id }) {
            self.chatMessages.remove(at: index)
        }
    }
}
