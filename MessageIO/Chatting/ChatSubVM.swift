//
//  ChatSubVM.swift
//  MessageIO
//
//  Copyright (c) 2024 z-wook. All right reserved.
//

import Foundation

final class ChatSubVM {
    enum ChatCellType {
        case left
        case right
    }
    enum KeyboardState {
        case show
        case hide
    }
    private(set) var chattings: [Chat]?
    let uid = UUID()
    var lastContentOffset: CGFloat?
    
    init() {
        print("init ChatSubVM")
        makeTestData()
    }
    
    deinit {
        print("deinit ChatSubVM")
    }
}

extension ChatSubVM {
    func makeTestData() {
        let tempData: [Chat] = [
            Chat(id: UUID(), name: "User", profileImg: nil, chat: "Dummy\nData", time: "15:41"),
            Chat(id: UUID(), name: "User", profileImg: nil, chat: "Swift", time: "15:42"),
            Chat(id: UUID(), name: "User", profileImg: nil, chat: "hello", time: "15:43"),
            Chat(id: UUID(), name: "User", profileImg: nil, chat: "hello world ~", time: "15:43"),
            Chat(id: UUID(), name: "User", profileImg: nil, chat: "This Is Test Data", time: "15:44"),
            Chat(id: UUID(), name: "User", profileImg: nil, chat: "Test\nData", time: "15:45"),
            Chat(id: UUID(), name: "User", profileImg: nil, chat: """
Long Text Long Text Long Text Long Text Long Text 
Long Text Long Text Long Text Long Text Long Text 
Long Text Long Text Long Text Long Text Long Text 
Long Text Long Text Long Text Long Text Long Text
""", time: "15:46"),
            Chat(id: UUID(), name: "User", profileImg: nil,
                          chat: "hello\nhello\nhello\nhello\nhello\nhello\nhello", time: "15:47"),
            Chat(id: UUID(), name: "User", profileImg: nil,
                          chat: "Chatting UI Test\nChatting Data\n\nMade By z-wook", time: "15:48")
        ]
        
        chattings = tempData // chattings에 저장
    }
    
    func addChat(chat: Chat) {
        chattings?.append(chat)
    }
    
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
        var constraintSize: CGSize
        let attributes: [NSAttributedString.Key: Any] = [.font: ThemeFont.chatLabelFont]
        
        // messageBoxView의 top, bottom inset
        let messageBoxViewInsets = AppConstraint.messageBoxInset * 2
        
        // chattingVStackView의 spacing
        let chatVStackSpacing = AppConstraint.chatVStackSpacing
        
        // chattingLabel의 top, bottom inset
        let chatLabelInsets = AppConstraint.chatLabelInset * 2
        
        var estimatedHeight: CGFloat
        
        switch chatCellType {
        case .left:
            constraintSize = CGSize(width: lblMaxWidth - (AppConstraint.leftChatLabelLeading + AppConstraint.chatLabelInset),
                                    height: .greatestFiniteMagnitude)
            
        case .right:
            constraintSize = CGSize(width: lblMaxWidth - (AppConstraint.rightChatLabelTrailing + AppConstraint.chatLabelInset),
                                    height: .greatestFiniteMagnitude)
        }
        
        let boundingBox = text.boundingRect(
            with: constraintSize,
            options: .usesLineFragmentOrigin,
            attributes: attributes,
            context: nil
        )
        
        switch chatCellType {
        case .left:
            estimatedHeight = AppConstraint.profileNameLabelSize
            + ceil(boundingBox.height)
            + messageBoxViewInsets
            + chatVStackSpacing
            + chatLabelInsets
            
        case .right:
            estimatedHeight = messageBoxViewInsets
            + ceil(boundingBox.height)
            + chatLabelInsets
        }
        
        return CGSize(width: cellWidth, height: estimatedHeight)
    }
    
    // 공백 체크를 하는 메서드
    func isOnlyWhitespace(text: String) -> Bool {
        return text.range(of: "^[\\s]*$", options: .regularExpression) != nil
    }
}
