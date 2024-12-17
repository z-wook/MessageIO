//
//  AppConstraint.swift
//  MessageIO
//
//  Copyright (c) 2024 z-wook. All right reserved.
//

import UIKit

struct AppConstraint {
    static let spacing4: CGFloat = 4
    static let spacing8: CGFloat = 8
    static let spacing10: CGFloat = 10
    static let spacing14: CGFloat = 14
    static let spacing16: CGFloat = 16
    static let spacing24: CGFloat = 24
}

extension AppConstraint {
    static let cornerRadius: CGFloat = 16
}

extension AppConstraint {
    static let chatLabelMaxWidth = UIScreen.main.bounds.width * 0.7
    static let messageBoxInset: CGFloat = 8
    static let chatLabelInset: CGFloat = 8
    static let chatHStackSpacing = 8
    static let chatVStackSpacing: CGFloat = 10
    static let leftChatLabelLeading: CGFloat = 14
    static let rightChatLabelTrailing: CGFloat = 14
    static let profileNameLabelSize: CGFloat = 20
    static let profileImageSize: CGFloat = 40
    static let timeLabelWidth: CGFloat = 50
}
