//
//  ANIProfileMenuBarCell.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/17.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import TinyConstraints

class ANIProfileMenuBarCell: UICollectionViewCell {
  
  var menuLabel: UILabel?
  var underBar: UIView?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    let menuLabel = UILabel()
    menuLabel.textAlignment = .center
    menuLabel.font = UIFont.boldSystemFont(ofSize: 13)
    menuLabel.textColor = ANIColor.bg
    addSubview(menuLabel)
    menuLabel.edgesToSuperview()
    self.menuLabel = menuLabel
    
    let underBar = UIView()
    underBar.backgroundColor = ANIColor.bg
    addSubview(underBar)
    underBar.centerXToSuperview()
    underBar.bottomToSuperview()
    underBar.width(30.0)
    underBar.height(2.0)
    self.underBar = underBar
  }
  
  override var isHighlighted: Bool {
    didSet {
      menuLabel?.textColor = isHighlighted ? ANIColor.dark : ANIColor.gray
      underBar?.backgroundColor = isHighlighted ? ANIColor.emerald : ANIColor.bg
    }
  }
  
  override var isSelected: Bool {
    didSet {
      menuLabel?.textColor = isSelected ? ANIColor.dark : ANIColor.gray
      underBar?.backgroundColor = isSelected ? ANIColor.emerald : ANIColor.bg
    }
  }
}
