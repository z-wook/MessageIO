//
//  ChatView.swift
//  MessageIO
//
//  Copyright (c) 2024 z-wook. All right reserved.
//

import SnapKit
import UIKit

final class ChatView: UIView {
    var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = ThemeColors.chatViewBgColor
        collectionView.register(LeftChatCell.self, forCellWithReuseIdentifier: LeftChatCell.identifier)
        collectionView.register(RightChatCell.self, forCellWithReuseIdentifier: RightChatCell.identifier)
        return collectionView
    }()
    
    init() {
        super.init(frame: .zero)
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ChatView {
    func setLayout() {
        addSubview(collectionView)
        
        collectionView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.bottom.equalTo(safeAreaLayoutGuide)
        }
    }
}
