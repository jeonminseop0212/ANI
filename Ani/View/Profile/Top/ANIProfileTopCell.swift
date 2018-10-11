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
  
  private weak var stackView: UIStackView?

  private weak var menuBar: ANIProfileMenuBar?
  private let MENU_BAR_HEIGHT: CGFloat = 60.0
  
  weak var bottomSpace: UIView?
  
  var user: FirebaseUser? {
    didSet {
      guard let familyView = self.familyView,
            let user = self.user else { return }
      
      familyView.user = user
    }
  }
  
  var delegate: ANIProfileMenuBarDelegate? {
    get { return self.menuBar?.delegate }
    set(v) { self.menuBar?.delegate = v }
  }
  
  var selectedIndex: Int? {
    didSet {
      reloadLayout()
    }
  }
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    self.selectionStyle = .none
    
    //familyView
    let familyView = ANIFamilyView()
    addSubview(familyView)
    familyView.topToSuperview()
    familyView.leftToSuperview()
    familyView.rightToSuperview()
    familyView.widthToSuperview()
    familyView.height(FAMILY_VIEW_HEIGHT)
    self.familyView = familyView
    
    //stackView
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.distribution = .equalSpacing
    addSubview(stackView)
    stackView.topToBottom(of: familyView, offset: 10.0)
    stackView.edgesToSuperview(excluding: .top)
    self.stackView = stackView

    //menuBar
    let menuBar = ANIProfileMenuBar()
    stackView.addArrangedSubview(menuBar)
    menuBar.height(MENU_BAR_HEIGHT)
    self.menuBar = menuBar
    
    //bottomSpace
    let bottomSpace = UIView()
    bottomSpace.backgroundColor = ANIColor.bg
    bottomSpace.height(10.0)
    stackView.addArrangedSubview(bottomSpace)
    self.bottomSpace = bottomSpace
  }
  
  private func reloadLayout() {
    guard let menuBar = self.menuBar,
          let selectedIndex = self.selectedIndex else { return }
    let indexPath = IndexPath(item: selectedIndex, section: 0)
    menuBar.menuCollectionView?.selectItem(at: indexPath, animated: false, scrollPosition: .left)
  }
}
