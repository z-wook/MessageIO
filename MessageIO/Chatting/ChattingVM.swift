//
//  ChattingVM.swift
//  MessageIO
//
//  Copyright (c) 2024 z-wook. All right reserved.
//

import Foundation

final class ChattingVM {
    private(set) var chattings: [ChattingModel]?
    var testData: [ChattingModel] = []
    
    init() {
        print("ChattingVM init")
        makeTestData()
    }
    
    deinit {
        print("ChattingVM deinit")
    }
}

extension ChattingVM {
    func makeTestData() {
        let tempData: [ChattingModel] = [
            ChattingModel(id: UUID(), name: "User", profileImg: nil, chatting: "hello", time: "15:43"),
            ChattingModel(id: UUID(), name: "User", profileImg: nil, chatting: "hello world ~", time: "15:43"),
            ChattingModel(id: UUID(), name: "User", profileImg: nil, chatting: "This Is Test Data", time: "15:44"),
            ChattingModel(id: UUID(), name: "User", profileImg: nil, chatting: "Test\nData", time: "15:45"),
            ChattingModel(id: UUID(), name: "User", profileImg: nil, chatting: """
Long Text Long Text Long Text Long Text Long Text 
Long Text Long Text Long Text Long Text Long Text 
Long Text Long Text Long Text Long Text Long Text 
Long Text Long Text Long Text Long Text Long Text
""", time: "15:46"),
            ChattingModel(id: UUID(), name: "User", profileImg: nil,
                          chatting: "hello\nhello\nhello\nhello\nhello\nhello\nhello", time: "15:47"),
            ChattingModel(id: UUID(), name: "User", profileImg: nil,
                          chatting: "Chatting UI Test\nChatting Data\n\nMade By z-wook", time: "15:48")
        ]
        
        self.chattings = tempData // chattings에 저장
    }
    
    /// 채팅 길이에 따라 LeftChattingCell의 높이를 계산하는 함수
    /// - Parameters:
    ///   - text: 채팅 text 데이터
    ///   - cellWidth: Cell 넓이
    ///   - lblMaxWidth: 채팅 라벨의 최대 길이
    /// - Returns: CGSize(Cell 넓이, Cell 높이)
    func calcEstimatedCellSize(text: String, cellWidth: CGFloat, lblMaxWidth: CGFloat) -> CGSize {
        let constraintSize = CGSize(width: lblMaxWidth - (AppConstraint.chattingLabelLeading
                                                          + AppConstraint.chattingLabelInset),
                                    height: .greatestFiniteMagnitude)
        
        let attributes: [NSAttributedString.Key: Any] = [.font: ThemeFont.chattingLabelFont]
        
        let boundingBox = text.boundingRect(
            with: constraintSize,
            options: .usesLineFragmentOrigin,
            attributes: attributes,
            context: nil
        )
        
        // messageBoxView의 top, bottom inset
        let messageBoxViewInsets = AppConstraint.messageBoxInset * 2
        
        // chattingVStackView의 spacing
        let chattingVStackSpacing = AppConstraint.chattingVStackSpacing
        
        // chattingLabel의 top, bottom inset
        let chattingInsets = AppConstraint.chattingLabelInset * 2
        
        let estimatedHeight = AppConstraint.profileNameLabelSize
        + ceil(boundingBox.height)
        + messageBoxViewInsets
        + chattingVStackSpacing
        + chattingInsets
        
        return CGSize(width: cellWidth, height: estimatedHeight)
    }
}
