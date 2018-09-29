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
  
  private weak var stackView: UIStackView?
  private weak var dateLabel: UILabel?
  private weak var base: UIView?
  private let PROFILE_IMAGE_VIEW_HEIGHT: CGFloat = 35.0
  private weak var profileImageView: UIImageView?
  private weak var messageBG: UIView?
  private weak var messageLabel: UILabel?
  private weak var timeLabel: UILabel?
  
  var message: FirebaseChatMessage?
  
  var user: FirebaseUser? {
    didSet {
      reloadUserLayout()
    }
  }
  
  var chagedDate: String? {
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
    
    //stackView
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.distribution = .fill
    addSubview(stackView)
    stackView.edgesToSuperview()
    self.stackView = stackView
    
    //dateLabel
    let dateLabel = UILabel()
    dateLabel.backgroundColor = .white
    dateLabel.textColor = ANIColor.darkGray
    dateLabel.font = UIFont.systemFont(ofSize: 15)
    dateLabel.textAlignment = .center
    dateLabel.isHidden = true
    stackView.addArrangedSubview(dateLabel)
    self.dateLabel = dateLabel
    
    //base
    let base = UIView()
    stackView.addArrangedSubview(base)
    self.base = base
    
    //profileImageView
    let profileImageView = UIImageView()
    profileImageView.layer.cornerRadius = PROFILE_IMAGE_VIEW_HEIGHT / 2
    profileImageView.layer.masksToBounds = true
    profileImageView.isUserInteractionEnabled = true
    profileImageView.backgroundColor = ANIColor.bg
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileTapped))
    profileImageView.addGestureRecognizer(tapGesture)
    base.addSubview(profileImageView)
    profileImageView.leftToSuperview(offset: 10.0)
    profileImageView.topToSuperview(offset: 5.0)
    profileImageView.width(PROFILE_IMAGE_VIEW_HEIGHT)
    profileImageView.height(PROFILE_IMAGE_VIEW_HEIGHT)
    self.profileImageView = profileImageView
    
    //messageBG
    let messageBG = UIView()
    messageBG.backgroundColor = ANIColor.bg
    messageBG.layer.cornerRadius = 10.0
    messageBG.layer.masksToBounds = true
    base.addSubview(messageBG)
    let width = UIScreen.main.bounds.width * 0.6
    messageBG.top(to: profileImageView)
    messageBG.leftToRight(of: profileImageView, offset: 10.0)
    messageBG.width(min: 0.0, max: width)
    messageBG.bottomToSuperview(offset: -5.0)
    self.messageBG = messageBG
    
    //messageLabel
    let messageLabel = UILabel()
    messageLabel.font = UIFont.systemFont(ofSize: 15.0)
    messageLabel.textColor = ANIColor.dark
    messageLabel.numberOfLines = 0
    messageBG.addSubview(messageLabel)
    let labelInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: -10.0)
    messageLabel.edgesToSuperview(insets: labelInsets)
    self.messageLabel = messageLabel
    
    
    //timeLabel
    let timeLabel = UILabel()
    timeLabel.textColor = ANIColor.darkGray
    timeLabel.font = UIFont.systemFont(ofSize: 13)
    base.addSubview(timeLabel)
    timeLabel.leftToRight(of: messageBG, offset: 4.0)
    timeLabel.bottom(to: messageBG)
    self.timeLabel = timeLabel
  }
  
  private func reloadLayout() {
    guard let dateLabel = self.dateLabel,
          let messageLabel = self.messageLabel,
          let message = self.message,
          let text = message.message,
          let timeLabel = self.timeLabel,
          let date = message.date else { return }
    
    if let chagedDate = self.chagedDate {
      dateLabel.isHidden = false
      dateLabel.text = chagedDate
    } else {
      dateLabel.isHidden = true
    }
    
    messageLabel.text = text
    
    let suffixString = String(date.suffix(8))
    timeLabel.text = String(suffixString.prefix(5))
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
