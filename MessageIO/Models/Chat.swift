//
//  Chat.swift
//  MessageIO
//
//  Copyright (c) 2024 z-wook. All right reserved.
//

import CryptoKit
import UIKit

enum MessageType: String, Codable {
    case text
    case image
    case video
    case file
}

struct EncryptedMessageData: Codable {
    let data: String
    let timeStamp: Date
}

struct ChatRoomSummary {
    let id: String                      // 채팅방 ID
    let groupKey: SymmetricKey          // 채팅방 그룹키
    var title: String?                  // 채팅방 이름
    var participantsID: [String]        // 참가자 ID 목록
    var lastMessage: ChatMessage?       // 마지막 메시지 내용
//    let lastMessageTimestamp: Date      // 마지막 메시지 시간
//    let unreadCount: Int                // 읽지 않은 메시지 개수
}

struct ChatRoom {
    let id: String                      // 채팅방 고유 ID
    var groupKey: SymmetricKey?         // 채팅방 그룹키
    var title: String?                  // 채팅방 이름 (단체방 이름)
    var participantsID: [String] = []   // 참가자 ID 목록
    //    var messages: [ChatMessage]         // 메시지 목록
}

struct ChatMessage: Codable {
    let id: String              // 메시지의 고유 식별자
    let senderId: String        // 보낸 사람의 ID
    var senderName: String      // 보낸 사람의 이름 (옵션)
    var type: MessageType       // 메시지 유형
    var content: String         // 메시지 내용 (텍스트, URL 등)
    let timestamp: Date         // 메시지 보낸 시간
    var isRead: Bool = false    // 수신 여부
}
