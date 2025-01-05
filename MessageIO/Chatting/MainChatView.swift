//
//  MainChatView.swift
//  MessageIO
//
//  Copyright (c) 2025 z-wook. All right reserved.
//

import SnapKit
import UIKit

final class MainChatView: UIView {
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.register(ChatListCell.self, forCellWithReuseIdentifier: ChatListCell.identifier)
        view.backgroundColor = ThemeColors.clearColor
        return view
    }()
    
    init() {
        super.init(frame: .zero)
        self.backgroundColor = ThemeColors.blackWithAlphaColor
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension MainChatView {
    func setUI() {
        addSubview(collectionView)
        
        collectionView.snp.makeConstraints {
            $0.edges.equalTo(safeAreaLayoutGuide)
        }
    }
}
