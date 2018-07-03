//
//  ANIMessageViewCell.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/15.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import FirebaseDatabase
import CodableFirebase

class ANIMessageViewCell: UITableViewCell {
  
  private let PROFILE_IMAGE_VIEW_HEIGHT: CGFloat = 50.0
  private weak var profileImageView: UIImageView?
  private weak var userNameLabel: UILabel?
  private weak var updateDateLabel: UILabel?
  private weak var subTitleLabel: UILabel?
  
  var chatGroup: FirebaseChatGroup? {
    didSet {
      reloadLayout()
    }
  }
  
  private var user: FirebaseUser?
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    self.selectionStyle = .none
    backgroundColor = .white
    self.isUserInteractionEnabled = true
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
    self.addGestureRecognizer(tapGesture)
    
    //profileImageView
    let profileImageView = UIImageView()
    profileImageView.backgroundColor = ANIColor.bg
    profileImageView.layer.cornerRadius = PROFILE_IMAGE_VIEW_HEIGHT / 2
    profileImageView.layer.masksToBounds = true
    addSubview(profileImageView)
    profileImageView.topToSuperview(offset: 10.0)
    profileImageView.leftToSuperview(offset: 10.0)
    profileImageView.width(PROFILE_IMAGE_VIEW_HEIGHT)
    profileImageView.height(PROFILE_IMAGE_VIEW_HEIGHT)
    self.profileImageView = profileImageView
    
    //userNameLabel
    let userNameLabel = UILabel()
    userNameLabel.textColor = ANIColor.dark
    userNameLabel.font = UIFont.systemFont(ofSize: 16.0)
    addSubview(userNameLabel)
    userNameLabel.topToSuperview(offset: 13.0)
    userNameLabel.leftToRight(of: profileImageView, offset: 10.0)
    userNameLabel.height(18.0)
    self.userNameLabel = userNameLabel
    
    //updateDateLabel
    let updateDateLabel = UILabel()
    updateDateLabel.textColor = ANIColor.darkGray
    updateDateLabel.font = UIFont.systemFont(ofSize: 11.0)
    addSubview(updateDateLabel)
    updateDateLabel.centerY(to: userNameLabel)
    updateDateLabel.leftToRight(of: userNameLabel, offset: 10.0)
    updateDateLabel.rightToSuperview()
    updateDateLabel.width(70.0)
    self.updateDateLabel = updateDateLabel
    
    //subTitleLabel
    let subTitleLabel = UILabel()
    subTitleLabel.numberOfLines = 2
    subTitleLabel.font = UIFont.systemFont(ofSize: 14.0)
    subTitleLabel.textColor = ANIColor.subTitle
    addSubview(subTitleLabel)
    subTitleLabel.topToBottom(of: userNameLabel, offset: 10.0)
    subTitleLabel.left(to: userNameLabel)
    subTitleLabel.rightToSuperview(offset: 10.0)
    self.subTitleLabel = subTitleLabel
    
    //bottomSpace
    let spaceView = UIView()
    spaceView.backgroundColor = ANIColor.bg
    addSubview(spaceView)
    spaceView.topToBottom(of: subTitleLabel, offset: 10)
    spaceView.leftToSuperview()
    spaceView.rightToSuperview()
    spaceView.height(10.0)
    spaceView.bottomToSuperview()
  }
  
  private func reloadLayout() {
    guard let updateDateLabel = self.updateDateLabel,
          let subTitleLabel = self.subTitleLabel,
          let chatGroup = self.chatGroup else { return }
    
    updateDateLabel.text = String(chatGroup.updateDate.prefix(10))
    subTitleLabel.text = chatGroup.lastMessage
  }
  
  private func reloadUserLayout(user: FirebaseUser) {
    guard let profileImageView = self.profileImageView,
          let userNameLabel = self.userNameLabel,
          let profileImageUrl = user.profileImageUrl else { return }
    
    profileImageView.sd_setImage(with: URL(string: profileImageUrl), completed: nil)
    userNameLabel.text = user.userName
  }
  
  func loadUser() {
    guard let chatGroup = self.chatGroup,
          let currentUserUid = ANISessionManager.shared.currentUserUid else { return }
    
    for memberId in chatGroup.memberIds.keys {
      if currentUserUid != memberId {
        DispatchQueue.global().async {
          let databaseRef = Database.database().reference()
          databaseRef.child(KEY_USERS).child(memberId).observeSingleEvent(of: .value, with: { (userSnapshot) in
            if let userValue = userSnapshot.value {
              do {
                let user = try FirebaseDecoder().decode(FirebaseUser.self, from: userValue)
                self.user = user
                
                DispatchQueue.main.async {
                  self.reloadUserLayout(user: user)
                }
              } catch let error {
                print(error)
              }
            }
          })
        }
      }
    }
  }
  
  func observeGroup() {
    guard let chatGroup = self.chatGroup else { return }
    
    let databaseRef = Database.database().reference()
    databaseRef.child(KEY_CHAT_GROUPS).child(chatGroup.groupId).observe(.value) { (snapshot) in
      if let groupValue = snapshot.value {
        do {
          let group = try FirebaseDecoder().decode(FirebaseChatGroup.self, from: groupValue)
          self.chatGroup = group
        } catch let error {
          print(error)
        }
      }
    }
  }
  
  @objc private func cellTapped() {
    guard let user = self.user else { return }
    
    ANINotificationManager.postMessageCellTapped(user: user)
  }
}
