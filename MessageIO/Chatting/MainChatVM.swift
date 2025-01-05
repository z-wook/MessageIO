//
//  MainChatVM.swift
//  MessageIO
//
//  Copyright (c) 2025 z-wook. All right reserved.
//

import Foundation

final class MainChatVM {
    private(set) var chattings: [Chat]?
    
    init() {
        print("init MainChatVM")
        makeTestData()
    }
    
    deinit {
        print("deinit MainChatVM")
    }
}

private extension MainChatVM {
    func makeTestData() {
        chattings = [
            Chat(id: UUID(), name: "Test1", profileImg: nil, chat: "첫 번째 테스트 데이터 생성", time: "15:37"),
            Chat(id: UUID(), name: "Test2", profileImg: nil, chat: "두 번째 테스트 데이터 생성...", time: "15:38"),
            Chat(id: UUID(), name: "Test3", profileImg: nil, chat: "세 번째 테스트 데이터 생성 !@#$", time: "15:39"),
            Chat(id: UUID(), name: "Test4", profileImg: nil, chat: "네 번째 테스트 데이터 생성", time: "15:50"),
            Chat(id: UUID(), name: "Test5", profileImg: nil, chat: "다섯 번째 테스트 데이터 생성\n다섯 번째 테스트 데이터 생성", time: "15:37"),
            Chat(id: UUID(), name: "Test6", profileImg: nil, chat: "여섯 번째 테스트 데이터 생성", time: "15:37"),
            Chat(id: UUID(), name: "Test7", profileImg: nil, chat: "일곱 번째 테스트 데이터 생성,일곱 번째 테스트 데이터 생성,일곱 번째 테스트 데이터 생성,일곱 번째 테스트 데이터 생성,일곱 번째 테스트 데이터 생성,일곱 번째 테스트 데이터 생성", time: "2025.01.01"),
            Chat(id: UUID(), name: "Test8", profileImg: nil, chat: "Test Data", time: "2025.01.02"),
            Chat(id: UUID(), name: "Test9", profileImg: nil, chat: "zzzzzzzzzzz", time: "2025.01.03"),
            Chat(id: UUID(), name: "Test9", profileImg: nil, chat: "테스트 데이터 생성 종료", time: "2025.01.105")
        ]
    }
}
