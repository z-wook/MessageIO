//
//  MainChatVC.swift
//  MessageIO
//
//  Copyright (c) 2024 z-wook. All right reserved.
//

import Combine
import CryptoKit
import SnapKit
import UIKit

final class MainChatVC: UIViewController {
    private let mainChatView = MainChatView()
    private let mainChatVM = MainChatVM()
    private lazy var rightBarButtonItem: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .add,
                                     target: self,
                                     action: #selector(makeChatRoom))
        return button
    }()
    private var cancellables = Set<AnyCancellable>()
    
    deinit {
        print("deinit ChatMainVC")
    }
    
    override func loadView() {
        super.loadView()
        view = mainChatView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNavigationBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainChatView.collectionView.delegate = self
        mainChatView.collectionView.dataSource = self
        bindAllMessages()
        
        Task {
            await mainChatVM.loadInitialMessages()
        }
    }
}

private extension MainChatVC {
    func setNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundEffect = UIBlurEffect(style: .regular)
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        navigationItem.rightBarButtonItems = [rightBarButtonItem]
    }
    
    func bindAllMessages() {
        mainChatVM.$chatRoomSummarys
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.mainChatView.collectionView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    @objc func makeChatRoom() {
        let alert = UIAlertController(title: "채팅방 만들기", message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            guard let self else { return }
            guard let email = alert.textFields?[0].text, !email.isEmpty == true else { return }
            Task {
                guard let user = AuthManager.shared.loadCurrentUserData() else {
                    self.showErrorAlert(message: "내 정보가 없습니다.")
                    return
                }
                guard let invitationUserID = await self.mainChatVM.getUserID(email: email) else {
                    self.showErrorAlert(message: "존재하지 않는 이메일 입니다.")
                    return
                }
                print("✅ invitationUserID: \(invitationUserID)")
                let chatRoom = ChatRoom(id: UUID().uuidString,
                                        participantsID: [user.uid, invitationUserID])
                let subChatVC = SubChatVC(subChatVM: SubChatVM(chatRoom: chatRoom))
                subChatVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(subChatVC, animated: true)
            }
        }
        alert.addTextField { textField in
            textField.placeholder = "상대방 Email 입력"
        }
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    func showErrorAlert(message: String) {
        let errorAlert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default)
        errorAlert.addAction(okAction)
        
        DispatchQueue.main.async {
            self.present(errorAlert, animated: true)
        }
    }
}

extension MainChatVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: AppConstraint.size80)
    }
}

extension MainChatVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mainChatVM.chatRoomSummarys.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ChatListCell.identifier,
            for: indexPath) as? ChatListCell else { return UICollectionViewCell() }
        cell.setData(data: mainChatVM.chatRoomSummarys[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let chatRoomSummary =  mainChatVM.chatRoomSummarys[indexPath.row]
        let chatRoom = ChatRoom(id: chatRoomSummary.id,
                 groupKey: chatRoomSummary.groupKey,
                 participantsID: chatRoomSummary.participantsID)
        let subChatVC = SubChatVC(subChatVM: SubChatVM(chatRoom: chatRoom))
        subChatVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(subChatVC, animated: true)
    }
}
