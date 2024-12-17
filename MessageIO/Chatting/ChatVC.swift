//
//  ChatVC.swift
//  MessageIO
//
//  Copyright (c) 2024 z-wook. All right reserved.
//

import UIKit

final class ChatVC: UIViewController {
    private let chatView = ChatView()
    private let chatVM = ChatVM()
    
    deinit {
        print("deinit ChattingVC")
    }
    
    override func loadView() {
        super.loadView()
        view = chatView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationBar()
        chatView.collectionView.delegate = self
        chatView.collectionView.dataSource = self
    }
}

private extension ChatVC {
    func setNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundEffect = UIBlurEffect(style: .dark)
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
}

extension ChatVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let chattings = chatVM.chattings else { return .zero }
        return chatVM.getEstimatedChatCellSize(chatCellType: .right,
                                               text: chattings[indexPath.row].chat,
                                               cellWidth: collectionView.bounds.width,
                                               lblMaxWidth: AppConstraint.chatLabelMaxWidth)
    }
}

extension ChatVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return chatVM.chattings?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: RightChatCell.identifier,
            for: indexPath) as? RightChatCell else { return UICollectionViewCell() }
        guard let chattings = chatVM.chattings else { return UICollectionViewCell() }
        cell.setData(data: chattings[indexPath.row])
        return cell
    }
}
