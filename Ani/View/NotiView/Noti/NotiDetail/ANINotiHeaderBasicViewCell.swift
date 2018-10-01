//
//  ANINotiHeaderViewCell.swift
//  Ani
//
//  Created by jeonminseop on 2018/09/06.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

class ANINotiHeaderBasicViewCell: UITableViewCell {
  
  private weak var headerLabel: UILabel?
  
  var headerText = "" {
    didSet {
      guard let headerLabel = self.headerLabel else { return }
      
      headerLabel.text = headerText
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
    backgroundColor = ANIColor.bg
    
    //headerLabel
    let headerLabel = UILabel()
    headerLabel.backgroundColor = ANIColor.bg
    headerLabel.textColor = ANIColor.dark
    headerLabel.font = UIFont.boldSystemFont(ofSize: 15.0)
    addSubview(headerLabel)
    headerLabel.topToSuperview(offset: 10.0)
    headerLabel.leftToSuperview(offset: 10.0)
    headerLabel.rightToSuperview(offset: -10.0)
    headerLabel.bottomToSuperview(offset: -10)
    self.headerLabel = headerLabel
  }
}
