//
//  ChatSubVC.swift
//  MessageIO
//
//  Copyright (c) 2024 z-wook. All right reserved.
//

import UIKit

final class ChatSubVC: UIViewController, KeyboardObserver {
    private let chatSubView = ChatSubView()
    private let chatSubVM = ChatSubVM()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        print("init ChatSubVC")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("deinit ChatSubVC")
    }
    
    override func loadView() {
        super.loadView()
        view = chatSubView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatSubView.collectionView.delegate = self
        chatSubView.collectionView.dataSource = self
        chatSubView.sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        setNavigationBar()
        setKeyboardObserver()
        hideKeyBoardWhenTappedScreen()
        chatSubVM.makeTestData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard chatSubVM.lastContentOffset == nil else { return }
        scrollToBottom(animation: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        removeKeyboardObserver()
    }
}

extension ChatSubVC {
    @objc func sendButtonTapped() {
        guard let chat = chatSubView.chatTextView.text else { return }
        if chatSubVM.isOnlyWhitespace(text: chat) { return }
        let newChat = Chat(id: chatSubVM.uid, name: "User", profileImg: nil, chat: chat, time: "20:53")
        chatSubVM.addChat(chat: newChat)
        chatSubView.chatTextView.text = ""
        chatSubView.collectionView.reloadData()
        scrollToBottom(animation: true)
    }
}

extension ChatSubVC {
    func keyboardWillShow(notification: Notification) {
        let key = UIResponder.keyboardFrameEndUserInfoKey
        guard let keyboardFrame = notification.userInfo?[key] as? CGRect else { return }
        let keyboardHeight = keyboardFrame.height
        let height = keyboardHeight - AppConstraint.chatTextViewHeight + AppConstraint.spacing8
        let currentOffset = chatSubView.collectionView.contentOffset.y
        let newOffset = max(currentOffset + height, 0)
        chatSubVM.lastContentOffset = newOffset
        
        chatSubView.remakeLayout(keyboardHeight: keyboardHeight, keyboardState: .show)
        chatSubView.layoutIfNeeded()
        chatSubView.collectionView.setContentOffset(CGPoint(x: 0, y: newOffset), animated: false)
    }
    
    func keyboardWillHide(notification: Notification) {
        let key = UIResponder.keyboardFrameEndUserInfoKey
        guard let keyboardFrame = notification.userInfo?[key] as? CGRect else { return }
        let keyboardHeight = keyboardFrame.height
        let currentOffset = self.chatSubView.collectionView.contentOffset.y
        let height = keyboardHeight - AppConstraint.chatBottomHStackViewHeight + AppConstraint.chatTextViewHeight + AppConstraint.spacing8
        let originOffset: CGFloat = -100    // collectionView의 Top Layout을 SuperView로 설정했기 때문에 origin을 -100으로 설정
        let newOffset = max(currentOffset - height, originOffset)
        chatSubVM.lastContentOffset = newOffset
        
        chatSubView.remakeLayout(keyboardHeight: keyboardHeight, keyboardState: .hide)
        chatSubView.layoutIfNeeded()
        chatSubView.collectionView.setContentOffset(CGPoint(x: 0, y: newOffset), animated: false)
    }
}

private extension ChatSubVC {
    func setNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundEffect = UIBlurEffect(style: .dark)
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    func scrollToBottom(animation: Bool) {
        guard let chatting = chatSubVM.chattings, chatting.isEmpty == false else { return }
        let lastItemIndex = IndexPath(item: chatting.count - 1, section: 0)
        
        DispatchQueue.main.async {
            self.chatSubView.collectionView.scrollToItem(at: lastItemIndex, at: .bottom, animated: animation)
        }
    }
}

extension ChatSubVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let chattings = chatSubVM.chattings else { return .zero }
        let cellType: ChatSubVM.ChatCellType = chattings[indexPath.row].id == chatSubVM.uid ? .right : .left
        return chatSubVM.getEstimatedChatCellSize(chatCellType: cellType,
                                                  text: chattings[indexPath.row].chat,
                                                  cellWidth: collectionView.bounds.width,
                                                  lblMaxWidth: AppConstraint.chatLabelMaxWidth)
    }
}

extension ChatSubVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return chatSubVM.chattings?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let chattings = chatSubVM.chattings else { return UICollectionViewCell() }
        let cellType: ChatSubVM.ChatCellType = chattings[indexPath.row].id == chatSubVM.uid ? .right : .left
        
        switch cellType {
        case .left:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: LeftChatCell.identifier,
                for: indexPath) as? LeftChatCell else { return UICollectionViewCell() }
            cell.setData(data: chattings[indexPath.row])
            return cell
            
        case .right:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: RightChatCell.identifier,
                for: indexPath) as? RightChatCell else { return UICollectionViewCell() }
            cell.setData(data: chattings[indexPath.row])
            return cell
        }
    }
}
