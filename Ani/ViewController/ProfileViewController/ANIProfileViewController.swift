//
//  ANIProfileViewController.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/17.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import TinyConstraints

class ANIProfileViewController: UIViewController {
  
//  private weak var familyView: ANIFamilyView?
//  private let FAMILY_VIEW_HEIGHT: CGFloat = 95.0
//
//  private weak var menuBar: ANIProfileMenuBar?
//  private let MENU_BAR_HEIGHT: CGFloat = 60.0
//
//  private weak var containerCollectionView: UICollectionView?
  
  private weak var profileBasicView: ANIProfileBasicView?
  
  override func viewDidLoad() {
        super.viewDidLoad()

      setup()
    }
  
  private func setup() {
    //basic
    Orientation.lockOrientation(.portrait)
    self.view.backgroundColor = .white
    self.navigationController?.navigationBar.isTranslucent = false
    self.navigationItem.title = "PROFILE"
    
    //profileBasicView
    let profileBasicView = ANIProfileBasicView()
    self.view.addSubview(profileBasicView)
    profileBasicView.edgesToSuperview()
    self.profileBasicView = profileBasicView
  }
}
