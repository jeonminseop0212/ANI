//
//  ANIUserSearchViewCell.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/16.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

class ANIUserSearchViewCell: UITableViewCell {
  
  private weak var stackView: UIStackView?
  private let PROFILE_IMAGE_VIEW_HEIGHT: CGFloat = 50.0
  var profileImageView: UIImageView?
  var userNameLabel: UILabel?
  var followButton: ANIAreaButtonView?
  private weak var followLabel: UILabel?
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    self.selectionStyle = .none
    
    //stackView
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.alignment = .center
    stackView.distribution = .fill
    stackView.spacing = 10.0
    addSubview(stackView)
    let insets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: -10.0)
    stackView.edgesToSuperview(insets: insets)
    self.stackView = stackView
    
    //profileImageView
    let profileImageView = UIImageView()
    profileImageView.layer.cornerRadius = PROFILE_IMAGE_VIEW_HEIGHT / 2
    profileImageView.layer.masksToBounds = true
    profileImageView.backgroundColor = ANIColor.bg
    stackView.addArrangedSubview(profileImageView)
    profileImageView.width(PROFILE_IMAGE_VIEW_HEIGHT)
    profileImageView.height(PROFILE_IMAGE_VIEW_HEIGHT)
    self.profileImageView = profileImageView
    
    //userNameLabel
    let userNameLabel = UILabel()
    userNameLabel.textColor = ANIColor.dark
    stackView.addArrangedSubview(userNameLabel)
    userNameLabel.centerY(to: profileImageView)
    self.userNameLabel = userNameLabel
    
    //followButton
    let followButton = ANIAreaButtonView()
    followButton.baseCornerRadius = 10.0
    followButton.base?.backgroundColor = ANIColor.green
    followButton.base?.layer.borderWidth = 1.8
    followButton.base?.layer.borderColor = ANIColor.green.cgColor
    followButton.delegate = self
    stackView.addArrangedSubview(followButton)
    followButton.centerY(to: profileImageView)
    followButton.width(85.0)
    followButton.height(30.0)
    self.followButton = followButton
    
    //followLabel
    let followLabel = UILabel()
    followLabel.font = UIFont.boldSystemFont(ofSize: 14)
    followLabel.textColor = .white
    followLabel.text = "フォロー"
    followLabel.textAlignment = .center
    followButton.addContent(followLabel)
    followLabel.edgesToSuperview()
    self.followLabel = followLabel
  }
}

//MARK: ANIButtonViewDelegate
extension ANIUserSearchViewCell: ANIButtonViewDelegate {
  func buttonViewTapped(view: ANIButtonView) {
    if view === followButton {
      print("follow")
    }
  }
}
