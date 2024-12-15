//
//  ChattingVC.swift
//  MessageIO
//
//  Copyright (c) 2024 z-wook. All right reserved.
//

import UIKit

final class ChattingVC: UIViewController {
    private let chattingView = ChattingView()
    private let chattingVM = ChattingVM()
    
    deinit {
        print("deinit ChattingVC")
    }
    
    override func loadView() {
        super.loadView()
        view = chattingView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationBar()
        chattingView.collectionView.delegate = self
        chattingView.collectionView.dataSource = self
    }
}

extension ChattingVC {
    func setNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundEffect = UIBlurEffect(style: .dark)
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
}

extension ChattingVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let chattings = chattingVM.chattings else { return .zero }
        return chattingVM.calcEstimatedCellSize(text: chattings[indexPath.row].chatting,
                                                cellWidth: collectionView.bounds.width,
                                                lblMaxWidth: AppConstraint.chattingLabelMaxWidth)
    }
}

extension ChattingVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return chattingVM.chattings?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: LeftChattingCell.identifier,
            for: indexPath) as? LeftChattingCell else { return UICollectionViewCell() }
        guard let chattings = chattingVM.chattings else { return UICollectionViewCell() }
        cell.setData(data: chattings[indexPath.row])
        return cell
    }
}
