//
//  SubChatVC.swift
//  MessageIO
//
//  Copyright (c) 2024 z-wook. All right reserved.
//

import Combine
import UIKit

final class SubChatVC: UIViewController, KeyboardObserver {
    private let subChatView = SubChatView()
    private let subChatVM: SubChatVM
    private var cancellables = Set<AnyCancellable>()
    
    init(subChatVM: SubChatVM) {
        self.subChatVM = subChatVM
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        bindChatMessages()
        
        subChatVM.fetchState = .initialLoad
        Task {
            await subChatVM.loadInitialMessages()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard subChatVM.isKeyboardVisible == nil else { return }
        subChatVM.isKeyboardVisible = false
        scrollToBottom(animation: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        FirestoreManager.shared.removeListener() // 실시간 채팅 리스너 제거
        removeKeyboardObserver()
    }
}

private extension SubChatVC {
    func bindChatMessages() {
        subChatVM.$chatMessages
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                guard subChatVM.chatMessages.isEmpty == false else { return }
                
                switch subChatVM.fetchState {
                case .initialLoad:
                    UIView.performWithoutAnimation {
                        self.subChatView.collectionView.reloadData()
                    }
                    scrollToBottom(animation: false)
                    
                case .loadMore:
                    let currentOffsetY = subChatView.collectionView.contentSize.height - subChatView.collectionView.contentOffset.y
                    
                    subChatView.collectionView.reloadData()
                    subChatView.collectionView.layoutIfNeeded()
                    subChatView.setNeedsLayout()
                    
                    subChatView.layoutSubviewsCompleted = {
                        let offsetY = self.subChatView.collectionView.contentSize.height - currentOffsetY
                        self.subChatView.collectionView.contentOffset.y = offsetY
                        self.subChatVM.isFetching = false
                    }
                    
                case .send:
                    UIView.performWithoutAnimation {
                        self.subChatView.collectionView.reloadData()
                    }
                    scrollToBottom(animation: true)
                    
                default:
                    break
                }
                
                subChatVM.fetchState = .nomal
            }
            .store(in: &cancellables)
    }
    
    @objc func sendButtonTapped() {
        guard let chat = subChatView.chatTextView.text else { return }
        guard let user = subChatVM.authManager.loadCurrentUserData() else { return }
        if subChatVM.isOnlyWhitespace(text: chat) { return }
        let newChatMessage = ChatMessage(id: UUID().uuidString, senderId: user.uid,
                                         senderName: "Temp", type: MessageType.text,
                                         content: chat, timestamp: Date())
        Task {
            subChatVM.fetchState = .send
            await subChatVM.sendMessageProcess(chatMessage: newChatMessage)
            subChatView.chatTextView.text = ""
        }
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
        let chatMessages = subChatVM.chatMessages
        guard chatMessages.isEmpty == false else { return }
        let lastItemIndex = IndexPath(item: chatMessages.count - 1, section: 0)
        
        DispatchQueue.main.async {
            self.subChatView.collectionView.scrollToItem(at: lastItemIndex, at: .bottom, animated: animation)
        }
    }
}

extension SubChatVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let chatMessages = subChatVM.chatMessages
        guard chatMessages.isEmpty == false else { return .zero }
        let cellType: SubChatVM.ChatCellType = chatMessages[indexPath.row].id == subChatVM.chatRoom.id ? .right : .left
        return subChatVM.getEstimatedChatCellSize(chatCellType: cellType,
                                                  text: chatMessages[indexPath.row].content,
                                                  cellWidth: collectionView.bounds.width,
                                                  lblMaxWidth: AppConstraint.chatLabelMaxWidth)
    }
}

extension SubChatVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return subChatVM.chatMessages.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let chatMessages = subChatVM.chatMessages
        guard let user = subChatVM.authManager.loadCurrentUserData(),
              chatMessages.isEmpty == false else { return UICollectionViewCell() }
        let cellType: SubChatVM.ChatCellType = chatMessages[indexPath.row].senderId == user.uid ? .right : .left
        
        switch cellType {
        case .left:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: LeftChatCell.identifier,
                for: indexPath) as? LeftChatCell else { return UICollectionViewCell() }
            cell.setData(data: chatMessages[indexPath.row])
            return cell
            
        case .right:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: RightChatCell.identifier,
                for: indexPath) as? RightChatCell else { return UICollectionViewCell() }
            cell.setData(data: chatMessages[indexPath.row])
            return cell
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !subChatVM.isFetching else { return }
        guard subChatVM.fetchState == .nomal else { return }
        let offsetY = scrollView.contentOffset.y
        
        if offsetY <= 50 {
            subChatVM.isFetching = true
            subChatVM.fetchState = .loadMore
            
            Task {
                await subChatVM.loadMoreMessages()
            }
        }
    }
}
