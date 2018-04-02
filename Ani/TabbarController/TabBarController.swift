//
//  TabBarController.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/02.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

  override func viewDidLoad() {
    super.viewDidLoad()
    let recruitVC = RecruitViewController()
    recruitVC.tabBarItem = UITabBarItem(tabBarSystemItem: .downloads, tag: 1)
    let recruitNV = UINavigationController(rootViewController: recruitVC)
    setViewControllers([recruitNV], animated: false)
  }
}
