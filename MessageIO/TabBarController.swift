//
//  TabBarController.swift
//  MessageIO
//
//  Copyright (c) 2024 z-wook. All right reserved.
//

import UIKit

final class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
}

private extension TabBarController {
    func configure() {
        let friendVC = UINavigationController(rootViewController: FriendVC())
        friendVC.tabBarItem = UITabBarItem(
            title: "친구",
            image: Icons.person,
            selectedImage: Icons.personFill)
        
        let chatVC = UINavigationController(rootViewController: ChatMainVC())
        chatVC.tabBarItem = UITabBarItem(
            title: "채팅",
            image: Icons.bubble,
            selectedImage: Icons.bubbleFill)
        
        viewControllers = [friendVC, chatVC]
        tabBar.tintColor = ThemeColors.systemTintColor
        
        let settingVC = UINavigationController(rootViewController: SettingVC())
        settingVC.tabBarItem = UITabBarItem(
            title: "세팅",
            image: Icons.gear,
            selectedImage: Icons.gearFill)
        
        viewControllers = [friendVC, chatVC, settingVC]
        tabBar.tintColor = ThemeColors.systemTintColor
    }
}
