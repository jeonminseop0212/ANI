//
//  ANIOtherProfileCell.swift
//  Ani
//
//  Created by jeonminseop on 2018/06/12.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

class ANIOtherProfileCell: UITableViewCell {
  
  private weak var nameLabel: UILabel?
  private weak var groupLabel: UILabel?
  private weak var introductionLabel: UILabel?
  
  var user: FirebaseUser? {
    didSet {
      reloadLayout()
    }
  }
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    backgroundColor = .clear
    self.selectionStyle = .none
    
    //nameLabel
    let nameLabel = UILabel()
    nameLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
    nameLabel.textColor = ANIColor.dark
    nameLabel.numberOfLines = 0
    addSubview(nameLabel)
    nameLabel.topToSuperview(offset: 10.0)
    nameLabel.leftToSuperview(offset: 10.0)
    nameLabel.rightToSuperview(offset: 10.0)
    self.nameLabel = nameLabel
    
    //groupLabel
    let groupLabel = UILabel()
    groupLabel.font = UIFont.systemFont(ofSize: 17.0)
    groupLabel.textAlignment = .center
    groupLabel.textColor = ANIColor.dark
    addSubview(groupLabel)
    groupLabel.topToBottom(of: nameLabel, offset: 10.0)
    groupLabel.leftToSuperview(offset: 10.0)
    self.groupLabel = groupLabel
    
    //introductionLabel
    let introductionLabel = UILabel()
    groupLabel.font = UIFont.systemFont(ofSize: 17.0)
    introductionLabel.numberOfLines = 0
    introductionLabel.textColor = ANIColor.dark
    addSubview(introductionLabel)
    introductionLabel.topToBottom(of: groupLabel, offset: 10.0)
    introductionLabel.leftToSuperview(offset: 10.0)
    introductionLabel.rightToSuperview(offset: 10.0)
    self.introductionLabel = introductionLabel
  }
  
  private func reloadLayout() {
    guard let nameLabel = self.nameLabel,
      let groupLabel = self.groupLabel,
      let introductionLabel = self.introductionLabel,
      let user = self.user else { return }
    
    nameLabel.text = user.userName
    groupLabel.text = user.kind
    introductionLabel.text = user.introduce
  }
}
