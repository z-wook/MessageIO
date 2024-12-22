//
//  ChatMainVC.swift
//  MessageIO
//
//  Copyright (c) 2024 z-wook. All right reserved.
//

import SnapKit
import UIKit

final class ChatMainVC: UIViewController {
    let tempButton: UIButton = {
        let button = UIButton()
        button.setTitle("Temp", for: .normal)
        button.setTitleColor(.red, for: .normal)
        return button
    }()
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundEffect = UIBlurEffect(style: .regular)
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tempButton.addTarget(self, action: #selector(temp), for: .touchUpInside)
        
        view.addSubview(tempButton)
        
        tempButton.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(100)
        }
    }
}

extension ChatMainVC {
    @objc func temp() {
        
        let chatSubVC = ChatSubVC()
        chatSubVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(chatSubVC, animated: true)
    }
}
