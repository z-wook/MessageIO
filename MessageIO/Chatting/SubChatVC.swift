//
//  SubChatVC.swift
//  MessageIO
//
//  Copyright (c) 2024 z-wook. All right reserved.
//

import UIKit

final class SubChatVC: UIViewController, KeyboardObserver {
    private let subChatView = SubChatView()
    private let subChatVM = SubChatVM()
    
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
        view = subChatView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subChatView.collectionView.delegate = self
        subChatView.collectionView.dataSource = self
        subChatView.sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        setNavigationBar()
        setKeyboardObserver()
        hideKeyBoardWhenTappedScreen()
        subChatVM.makeTestData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard subChatVM.isKeyboardVisible == nil else { return }
        subChatVM.isKeyboardVisible = false
        scrollToBottom(animation: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        removeKeyboardObserver()
    }
}

extension SubChatVC {
    @objc func sendButtonTapped() {
        guard let chat = subChatView.chatTextView.text else { return }
        if subChatVM.isOnlyWhitespace(text: chat) { return }
        let newChat = Chat(id: subChatVM.uid, name: "User", profileImg: nil, chat: chat, time: "20:53")
        subChatVM.addChat(chat: newChat)
        subChatView.chatTextView.text = ""
        subChatView.collectionView.reloadData()
        scrollToBottom(animation: true)
    }
}

extension SubChatVC {
    func keyboardWillShow(notification: Notification) {
        guard let isKeyboardVisible = subChatVM.isKeyboardVisible,
              isKeyboardVisible == false else { return }
        subChatVM.isKeyboardVisible = true
        
        let key = UIResponder.keyboardFrameEndUserInfoKey
        guard let keyboardFrame = notification.userInfo?[key] as? CGRect else { return }
        let keyboardHeight = keyboardFrame.height
        let height = keyboardHeight - AppConstraint.size40 + AppConstraint.size8
        let currentOffset = subChatView.collectionView.contentOffset.y
        let newOffset = max(currentOffset + height, 0)
        
        subChatView.remakeLayout(keyboardHeight: keyboardHeight, keyboardState: .show)
        subChatView.layoutIfNeeded()
        subChatView.collectionView.setContentOffset(CGPoint(x: 0, y: newOffset), animated: false)
    }
    
    func keyboardWillHide(notification: Notification) {
        guard let isKeyboardVisible = subChatVM.isKeyboardVisible,
              isKeyboardVisible == true else { return }
        subChatVM.isKeyboardVisible = false
        
        let key = UIResponder.keyboardFrameEndUserInfoKey
        guard let keyboardFrame = notification.userInfo?[key] as? CGRect else { return }
        let keyboardHeight = keyboardFrame.height
        let currentOffset = self.subChatView.collectionView.contentOffset.y
        let height = keyboardHeight - AppConstraint.size80 + AppConstraint.size40 + AppConstraint.size8
        let originOffset: CGFloat = -100    // collectionView의 Top Layout을 SuperView로 설정했기 때문에 origin을 -100으로 설정
        let newOffset = max(currentOffset - height, originOffset)
        
        subChatView.remakeLayout(keyboardHeight: keyboardHeight, keyboardState: .hide)
        subChatView.layoutIfNeeded()
        subChatView.collectionView.setContentOffset(CGPoint(x: 0, y: newOffset), animated: false)
    }
}

private extension SubChatVC {
    func setNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundEffect = UIBlurEffect(style: .dark)
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    func scrollToBottom(animation: Bool) {
        guard let chatting = subChatVM.chattings, chatting.isEmpty == false else { return }
        let lastItemIndex = IndexPath(item: chatting.count - 1, section: 0)
        
        DispatchQueue.main.async {
            self.subChatView.collectionView.scrollToItem(at: lastItemIndex, at: .bottom, animated: animation)
        }
    }
}

extension SubChatVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let chattings = subChatVM.chattings else { return .zero }
        let cellType: SubChatVM.ChatCellType = chattings[indexPath.row].id == subChatVM.uid ? .right : .left
        return subChatVM.getEstimatedChatCellSize(chatCellType: cellType,
                                                  text: chattings[indexPath.row].chat,
                                                  cellWidth: collectionView.bounds.width,
                                                  lblMaxWidth: AppConstraint.chatLabelMaxWidth)
    }
}

extension SubChatVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return subChatVM.chattings?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let chattings = subChatVM.chattings else { return UICollectionViewCell() }
        let cellType: SubChatVM.ChatCellType = chattings[indexPath.row].id == subChatVM.uid ? .right : .left
        
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
