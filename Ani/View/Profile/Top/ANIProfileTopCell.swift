//
//  ANIProfileTopCell.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/19.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

class ANIProfileTopCell: UITableViewCell {
  
  private weak var familyView: ANIFamilyView?
  private let FAMILY_VIEW_HEIGHT: CGFloat = 95.0

  private weak var menuBar: ANIProfileMenuBar?
  private let MENU_BAR_HEIGHT: CGFloat = 60.0
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    //familyView
    let familyView = ANIFamilyView()
    addSubview(familyView)
    familyView.topToSuperview()
    familyView.leftToSuperview()
    familyView.rightToSuperview()
    familyView.widthToSuperview()
    familyView.height(FAMILY_VIEW_HEIGHT)
    self.familyView = familyView

    //menuBar
    let menuBar = ANIProfileMenuBar()
    addSubview(menuBar)
    menuBar.topToBottom(of: familyView, offset: 10.0)
    menuBar.leftToSuperview()
    menuBar.rightToSuperview()
    menuBar.widthToSuperview()
    menuBar.height(MENU_BAR_HEIGHT)
    menuBar.bottomToSuperview()
    self.menuBar = menuBar
  }
}
