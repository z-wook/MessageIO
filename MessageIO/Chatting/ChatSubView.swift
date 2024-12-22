//
//  ChatSubView.swift
//  MessageIO
//
//  Copyright (c) 2024 z-wook. All right reserved.
//

import SnapKit
import UIKit

final class ChatSubView: UIView {
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(LeftChatCell.self, forCellWithReuseIdentifier: LeftChatCell.identifier)
        collectionView.register(RightChatCell.self, forCellWithReuseIdentifier: RightChatCell.identifier)
        return collectionView
    }()
    
    private let bottomHStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .top
        view.distribution = .fill
        view.spacing = AppConstraint.spacing10
        return view
    }()
    
    let chatTextView: UITextView = {
        let view = UITextView()
        view.font = ThemeFont.chatTextViewFont
        view.textColor = .label
        view.keyboardType = .default
        view.backgroundColor = .systemGray
        view.layer.cornerRadius = AppConstraint.cornerRadius
        view.clipsToBounds = true
        return view
    }()
    
    let sendButton: UIButton = {
        let button = UIButton()
        button.imageView?.contentMode = .scaleAspectFit
        button.setImage(.send, for: .normal)
        return button
    }()
    
    init() {
        super.init(frame: .zero)
        self.backgroundColor = ThemeColors.chatSubViewBgColor
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ChatSubView {
    func setLayout() {
        [collectionView, bottomHStackView].forEach {
            addSubview($0)
        }
        
        [chatTextView, sendButton].forEach {
            bottomHStackView.addArrangedSubview($0)
        }
        
        collectionView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.bottom.equalTo(bottomHStackView.snp.top)
        }
        
        bottomHStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(AppConstraint.spacing10)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(AppConstraint.chatBottomHStackViewHeight)
        }
        
        chatTextView.snp.makeConstraints {
            $0.height.equalTo(AppConstraint.chatTextViewHeight)
        }
        
        sendButton.snp.makeConstraints {
            $0.width.height.equalTo(AppConstraint.sendButtonSize)
        }
    }
}

extension ChatSubVC {
    func remakeLayout() {
        
    }
}
