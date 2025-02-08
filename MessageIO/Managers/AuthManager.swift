//
//  AuthManager.swift
//  MessageIO
//
//  Copyright (c) 2025 z-wook. All right reserved.
//

import FirebaseAuth
import Foundation

final class AuthManager {
    static let shared = AuthManager()
    private let auth = Auth.auth()
    private init() {}
}

extension AuthManager {
    /// 회원가입 시 사용하는 메서드(이메일 회원가입)
    /// - Parameters:
    ///   - email: 가입할 이메일(아이디)
    ///   - password: 비밀번호
    func createUsers(email: String, password: String) async throws {
        let user = try await auth.createUser(withEmail: email, password: password)
        print("User ID : \(user.user.uid)")
    }
    
    func emailLogin(email: String, password: String) async throws {
        let user = try await auth.signIn(withEmail: email, password: password)
        print("User ID : \(user.user.uid)")
    }
    
    /// 현재 로그인한 유저 데이터를 가져오는 메서드
    /// - Returns: 로그인한 유저정보
    func loadCurrentUserData() -> User? {
        return auth.currentUser
    }
}
