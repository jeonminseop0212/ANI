//
//  CommunityViewController.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/08.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import TinyConstraints

class ANICommunityViewController: UIViewController {
  static let STATUS_BAR_HEIGHT: CGFloat = 20.0
  static let NAVIGATION_BAR_HEIGHT: CGFloat = 44.0
  
  private weak var menuBar: ANICommunityMenuBar?
  private weak var communityView: ANICommunityView?

  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  private func setup() {
    Orientation.lockOrientation(.portrait)
    navigationController?.setNavigationBarHidden(true, animated: false)

    self.view.backgroundColor = .white
    
    let communityView = ANICommunityView()
    self.view.addSubview(communityView)
    communityView.edgesToSuperview()
    self.communityView = communityView
    
    let menuBar = ANICommunityMenuBar()
    self.view.addSubview(menuBar)
    let menuBarHeight = ANICommunityViewController.STATUS_BAR_HEIGHT + ANICommunityViewController.NAVIGATION_BAR_HEIGHT
    menuBar.topToSuperview()
    menuBar.leftToSuperview()
    menuBar.rightToSuperview()
    menuBar.height(menuBarHeight)
    self.menuBar = menuBar
  }
}
