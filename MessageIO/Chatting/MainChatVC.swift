//
//  MainChatVC.swift
//  MessageIO
//
//  Copyright (c) 2024 z-wook. All right reserved.
//

import SnapKit
import UIKit

final class MainChatVC: UIViewController {
    private let mainChatView = MainChatView()
    private let mainChatVM = MainChatVM()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        print("init ChatMainVC")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    }
}

private extension MainChatVC {
    func setNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundEffect = UIBlurEffect(style: .regular)
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
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
        return mainChatVM.chattings?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let chattings = mainChatVM.chattings else { return UICollectionViewCell() }
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ChatListCell.identifier,
            for: indexPath) as? ChatListCell else { return UICollectionViewCell() }
        cell.setData(data: chattings[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let chatSubVC = SubChatVC()
        chatSubVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(chatSubVC, animated: true)
    }
}
