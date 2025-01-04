//
//  SubChatView.swift
//  MessageIO
//
//  Copyright (c) 2024 z-wook. All right reserved.
//

import SnapKit
import UIKit

final class SubChatView: UIView {
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
        view.spacing = AppConstraint.size10
        return view
    }()
    
    let chatTextView: UITextView = {
        let view = UITextView()
        view.font = ThemeFont.regular16Font
        view.textColor = .label
        view.keyboardType = .default
        view.backgroundColor = .systemGray
        view.layer.cornerRadius = AppConstraint.radius16
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
        self.backgroundColor = ThemeColors.blackWithAlphaColor
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension SubChatView {
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
            $0.leading.trailing.equalToSuperview().inset(AppConstraint.size10)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(AppConstraint.size80)
        }
        
        chatTextView.snp.makeConstraints {
            $0.height.equalTo(AppConstraint.size40)
        }
        
        sendButton.snp.makeConstraints {
            $0.width.height.equalTo(AppConstraint.size40)
        }
    }
}

extension SubChatView {
    func remakeLayout(keyboardHeight: CGFloat, keyboardState: SubChatVM.KeyboardState) {
        switch keyboardState {
        case .show:
            bottomHStackView.snp.remakeConstraints {
                $0.leading.trailing.equalToSuperview().inset(AppConstraint.size10)
                $0.bottom.equalToSuperview().inset(keyboardHeight)
                $0.height.equalTo(AppConstraint.size40 + AppConstraint.size8)
            }
            
        case .hide:
            bottomHStackView.snp.remakeConstraints {
                $0.leading.trailing.equalToSuperview().inset(AppConstraint.size10)
                $0.bottom.equalToSuperview()
                $0.height.equalTo(AppConstraint.size80)
            }
        }
        
        collectionView.snp.remakeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.bottom.equalTo(bottomHStackView.snp.top)
        }
    }
}
