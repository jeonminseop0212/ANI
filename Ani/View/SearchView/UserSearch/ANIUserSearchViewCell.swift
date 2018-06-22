//
//  ANIUserSearchViewCell.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/16.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

class ANIUserSearchViewCell: UITableViewCell {
  
  private let PROFILE_IMAGE_VIEW_HEIGHT: CGFloat = 50.0
  var profileImageView = UIImageView()
  var userNameLabel = UILabel()
  var followButton = UIButton()
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    self.selectionStyle = .none
    
    //profileImageView
    let profileImageView = UIImageView()
    profileImageView.layer.cornerRadius = PROFILE_IMAGE_VIEW_HEIGHT / 2
    profileImageView.layer.masksToBounds = true
    profileImageView.backgroundColor = ANIColor.bg
    addSubview(profileImageView)
    profileImageView.topToSuperview(offset: 10.0)
    profileImageView.leftToSuperview(offset: 10.0)
    profileImageView.width(PROFILE_IMAGE_VIEW_HEIGHT)
    profileImageView.height(PROFILE_IMAGE_VIEW_HEIGHT)
    profileImageView.bottomToSuperview(offset: -10.0)
    self.profileImageView = profileImageView
    
    //followButton
    let followButton = UIButton()
    followButton.setTitle("FOLLOW", for: .normal)
    followButton.addTarget(self, action: #selector(follow), for: .touchUpInside)
    followButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
    followButton.layer.cornerRadius = 5.0
    followButton.layer.masksToBounds = true
    followButton.backgroundColor = ANIColor.green
    addSubview(followButton)
    followButton.centerY(to: profileImageView)
    followButton.rightToSuperview(offset: 10.0)
    followButton.width(80.0)
    followButton.height(30.0)
    self.followButton = followButton
    
    //userNameLabel
    let userNameLabel = UILabel()
    userNameLabel.textColor = ANIColor.dark
    addSubview(userNameLabel)
    userNameLabel.centerY(to: profileImageView)
    userNameLabel.leftToRight(of: profileImageView, offset: 10.0)
    userNameLabel.rightToLeft(of: followButton, offset: 10.0)
    self.userNameLabel = userNameLabel
  }
  
  @objc private func follow() {
    print("following")
  }
}
