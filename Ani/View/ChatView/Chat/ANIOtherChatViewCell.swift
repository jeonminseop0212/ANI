//
//  ANIOtherChatViewCell.swift
//  Ani
//
//  Created by jeonminseop on 2018/06/27.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import Firebase
import CodableFirebase

class ANIOtherChatViewCell: UITableViewCell {
  private let PROFILE_IMAGE_VIEW_HEIGHT: CGFloat = 35.0
  private weak var profileImageView: UIImageView?
  private weak var base: UIView?
  private weak var messageLabel: UILabel?
  
  var message: FirebaseChatMessage? {
    didSet {
      reloadLayout()
    }
  }
  
  var user: FirebaseUser? {
    didSet {
      reloadUserLayout()
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
    self.selectionStyle = .none
    
    //profileImageView
    let profileImageView = UIImageView()
    profileImageView.layer.cornerRadius = PROFILE_IMAGE_VIEW_HEIGHT / 2
    profileImageView.layer.masksToBounds = true
    profileImageView.isUserInteractionEnabled = true
    profileImageView.backgroundColor = ANIColor.bg
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileTapped))
    profileImageView.addGestureRecognizer(tapGesture)
    addSubview(profileImageView)
    profileImageView.leftToSuperview(offset: 10.0)
    profileImageView.topToSuperview(offset: 5.0)
    profileImageView.width(PROFILE_IMAGE_VIEW_HEIGHT)
    profileImageView.height(PROFILE_IMAGE_VIEW_HEIGHT)
    self.profileImageView = profileImageView
    
    //base
    let base = UIView()
    base.backgroundColor = ANIColor.bg
    base.layer.cornerRadius = 10.0
    base.layer.masksToBounds = true
    addSubview(base)
    let width = UIScreen.main.bounds.width * 0.6
    base.top(to: profileImageView)
    base.leftToRight(of: profileImageView, offset: 10.0)
    base.width(min: 0.0, max: width)
    base.bottomToSuperview(offset: -5.0)
    self.base = base
    
    //messageLabel
    let messageLabel = UILabel()
    messageLabel.font = UIFont.systemFont(ofSize: 15.0)
    messageLabel.textColor = ANIColor.dark
    messageLabel.numberOfLines = 0
    base.addSubview(messageLabel)
    let labelInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: -10.0)
    messageLabel.edgesToSuperview(insets: labelInsets)
    self.messageLabel = messageLabel
  }
  
  private func reloadLayout() {
    guard let messageLabel = self.messageLabel,
          let message = self.message,
          let text = message.message else { return }
    
    messageLabel.text = text
  }
  
  private func reloadUserLayout() {
    guard let profileImageView = self.profileImageView,
          let user = self.user,
          let profileImageUrl = user.profileImageUrl else { return }
    
    profileImageView.sd_setImage(with: URL(string: profileImageUrl), completed: nil)
  }
  
  @objc private func profileTapped() {
    guard let user = self.user,
          let userId = user.uid else { return }
    
    ANINotificationManager.postProfileImageViewTapped(userId: userId)
  }
}
