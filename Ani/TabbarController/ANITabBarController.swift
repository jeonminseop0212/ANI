//
//  TabBarController.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/02.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

class ANITabBarController: UITabBarController {

  override func viewDidLoad() {
    super.viewDidLoad()
    //tabBar上の線を消す
    let tabBarAppearane = UITabBar.appearance()
    tabBarAppearane.barTintColor = .white
    tabBar.alpha = 0.95
    tabBar.layer.borderWidth = 0.0
    tabBar.clipsToBounds = true
    
    let recruitVC = ANIRecruitViewController()
    recruitVC.tabBarItem = UITabBarItem(tabBarSystemItem: .downloads, tag: 1)
    let recruitNV = ScrollingNavigationController(rootViewController: recruitVC)
    
    let communityVC = ANICommunityViewController()
    communityVC.tabBarItem = UITabBarItem(tabBarSystemItem: .bookmarks, tag: 2)
    let communityNV = UINavigationController(rootViewController: communityVC)
    setViewControllers([recruitNV, communityNV], animated: false)
  }
}
