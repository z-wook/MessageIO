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
        chatSubView.chatTextView.delegate = self
        chatSubView.sendButton.addTarget(self,
                                         action: #selector(sendButtonTapped),
                                         for: .touchUpInside)
        
        setKeyboardObserver()
        hideKeyBoardWhenTappedScreen()
        chatSubVM.makeTestData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundEffect = UIBlurEffect(style: .dark)
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollToBottom()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        removeKeyboardObserver()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.resignFirstResponder()
    }
}

extension ChatSubVC {
    @objc func sendButtonTapped() {
        print(chatSubVM.testData)
        guard let chat = chatSubView.chatTextView.text else { return }
        let newChat = Chat(id: UUID(), name: "User", profileImg: nil, chat: chat, time: "20:53")
        chatSubVM.testData.append(newChat)
        print("=====")
        print(chatSubVM.testData)
        
        chatSubView.collectionView.reloadData()
    }
}

extension ChatSubVC {
    func keyboardWillShow(notification: Notification) {
        if self.view.window?.frame.origin.y == 0 {
            if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                let keyboardHeight = keyboardRectangle.height
                let bottomSapcing = AppConstraint.chatBottomHStackViewHeight - AppConstraint.chatTextViewHeight - AppConstraint.spacing8
                
                UIView.animate(withDuration: 1) {
                    self.view.window?.frame.origin.y -= keyboardHeight - bottomSapcing
                }
            }
        }
    }
    
    func keyboardWillHide(notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            let bottomSapcing = AppConstraint.chatBottomHStackViewHeight - AppConstraint.chatTextViewHeight - AppConstraint.spacing8
            
            UIView.animate(withDuration: 1) {
                self.view.window?.frame.origin.y += keyboardHeight - bottomSapcing
            }
        }
    }
}

private extension ChatSubVC {
    func setNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundEffect = UIBlurEffect(style: .dark)
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    func scrollToBottom() {
        let lastSectionIndex = chatSubView.collectionView.numberOfSections - 1
        if lastSectionIndex >= 0 {
            let lastItemIndex = chatSubView.collectionView.numberOfItems(inSection: lastSectionIndex) - 1
            if lastItemIndex >= 0 {
                let indexPath = IndexPath(item: lastItemIndex, section: lastSectionIndex)
                chatSubView.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
            }
        }
    }
}

extension ChatSubVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let chattings = chatSubVM.chattings else { return .zero }
        return chatSubVM.getEstimatedChatCellSize(chatCellType: .left,
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
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: LeftChatCell.identifier,
            for: indexPath) as? LeftChatCell else { return UICollectionViewCell() }
        guard let chattings = chatSubVM.chattings else { return UICollectionViewCell() }
        cell.setData(data: chattings[indexPath.row])
        return cell
    }
}

extension ChatSubVC: UITextViewDelegate {
//    func textViewDidChange(_ textView: UITextView) {
//        <#code#>
//    }
    
//    override func keyboardWillShow(notification: NSNotification) {
//        <#code#>
//    }
}
