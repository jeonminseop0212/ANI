//
//  profileTableViewCell.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/18.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

class ANIProfileCell: UITableViewCell {
  
  private weak var nameLabel: UILabel?
  private let PROFILE_EDIT_BUTTON_HEIGHT: CGFloat = 30.0
  private weak var profileEditButton: ANIAreaButtonView?
  private weak var profileEditLabel: UILabel?
  private weak var groupLabel: UILabel?
  private weak var introductionLabel: UILabel?
  
  var user: User? {
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
    
    //profileEditButton
    let profileEditButton = ANIAreaButtonView()
    profileEditButton.base?.backgroundColor = ANIColor.green
    profileEditButton.baseCornerRadius = PROFILE_EDIT_BUTTON_HEIGHT / 2
    profileEditButton.delegate = self
    addSubview(profileEditButton)
    profileEditButton.topToSuperview(offset: 10.0)
    profileEditButton.rightToSuperview(offset: 10.0)
    profileEditButton.width(60.0)
    profileEditButton.height(PROFILE_EDIT_BUTTON_HEIGHT)
    self.profileEditButton = profileEditButton
    
    //profileEditLabel
    let profileEditLabel = UILabel()
    profileEditLabel.textColor = .white
    profileEditLabel.text = "更新"
    profileEditLabel.textAlignment = .center
    profileEditLabel.font = UIFont.boldSystemFont(ofSize: 15)
    profileEditButton.addSubview(profileEditLabel)
    profileEditLabel.edgesToSuperview()
    self.profileEditLabel = profileEditLabel
    
    //nameLabel
    let nameLabel = UILabel()
    nameLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
    nameLabel.textColor = ANIColor.dark
    nameLabel.numberOfLines = 0
    addSubview(nameLabel)
    nameLabel.topToSuperview(offset: 10.0)
    nameLabel.leftToSuperview(offset: 10.0)
    nameLabel.rightToLeft(of: profileEditButton, offset: -10.0)
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
    
    nameLabel.text = user.name
    
    groupLabel.text = user.kind
    
    introductionLabel.text = user.introduce
  }
}

//MARK: ANIButtonViewDelegate
extension ANIProfileCell: ANIButtonViewDelegate {
  func buttonViewTapped(view: ANIButtonView) {
    if view === self.profileEditButton {
      ANINotificationManager.postProfileEditButtonTapped()
    }
  }
}
