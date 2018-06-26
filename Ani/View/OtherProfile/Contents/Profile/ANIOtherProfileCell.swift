//
//  ANIOtherProfileCell.swift
//  Ani
//
//  Created by jeonminseop on 2018/06/12.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ANIOtherProfileCell: UITableViewCell {
  
  private weak var nameLabel: UILabel?
  private let FOLLOW_BUTTON_HEIGHT: CGFloat = 30.0
  private let FOLLOW_BUTTON_WIDTH: CGFloat = 100.0
  private weak var followButton: ANIAreaButtonView?
  private weak var followLabel: UILabel?
  private weak var followingBG: UIView?
  private weak var followingCountLabel: UILabel?
  private weak var followingLabel: UILabel?
  private weak var followerBG: UIView?
  private weak var followerCountLabel: UILabel?
  private weak var followerLabel: UILabel?
  private weak var groupLabel: UILabel?
  private weak var introduceBG: UIView?
  private weak var introductionLabel: UILabel?
  
  var user: FirebaseUser? {
    didSet {
      reloadLayout()
      isFollowed()
      
      if let uid = user?.uid, userId == nil {
        userId = uid
      }
    }
  }
  
  private var userId: String? {
    didSet {
      observeUserFollow()
    }
  }
  
  private var followUserIds = [String: String]() {
    didSet {
      reloadFollowLayout()
    }
  }
  private var followingUserIds = [String: String](){
    didSet {
      reloadFollowLayout()
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
    
    //followButton
    let followButton = ANIAreaButtonView()
    followButton.base?.backgroundColor = ANIColor.green
    followButton.baseCornerRadius = FOLLOW_BUTTON_HEIGHT / 2
    followButton.delegate = self
    followButton.base?.layer.borderWidth = 1.8
    followButton.base?.layer.borderColor = ANIColor.green.cgColor
    addSubview(followButton)
    followButton.topToSuperview(offset: 10.0)
    followButton.rightToSuperview(offset: 10.0)
    followButton.width(FOLLOW_BUTTON_WIDTH)
    followButton.height(FOLLOW_BUTTON_HEIGHT)
    self.followButton = followButton
    
    //followLabel
    let followLabel = UILabel()
    followLabel.textColor = .white
    followLabel.text = "フォロー"
    followLabel.textAlignment = .center
    followLabel.font = UIFont.boldSystemFont(ofSize: 15)
    followButton.addContent(followLabel)
    followLabel.edgesToSuperview()
    self.followLabel = followLabel
    
    //nameLabel
    let nameLabel = UILabel()
    nameLabel.font = UIFont.boldSystemFont(ofSize: 19.0)
    nameLabel.textColor = ANIColor.dark
    nameLabel.numberOfLines = 0
    addSubview(nameLabel)
    nameLabel.topToSuperview(offset: 10.0)
    nameLabel.leftToSuperview(offset: 10.0)
    nameLabel.rightToLeft(of: followButton, offset: -10.0)
    self.nameLabel = nameLabel
    
    //followingBG
    let followingBG = UIView()
    followingBG.isUserInteractionEnabled = true
    let followingTapGesture = UITapGestureRecognizer(target: self, action: #selector(followingTapped))
    followingBG.addGestureRecognizer(followingTapGesture)
    addSubview(followingBG)
    followingBG.topToBottom(of: nameLabel, offset: 10.0)
    followingBG.leftToSuperview(offset: 10.0)
    self.followingBG = followingBG
    
    //followingCountLabel
    let followingCountLabel = UILabel()
    followingCountLabel.text = "0"
    followingCountLabel.textColor = ANIColor.dark
    followingCountLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
    followingBG.addSubview(followingCountLabel)
    followingCountLabel.edgesToSuperview(excluding: .right)
    self.followingCountLabel = followingCountLabel
    
    //followingLabel
    let followingLabel = UILabel()
    followingLabel.text = "フォロー中"
    followingLabel.textColor = ANIColor.subTitle
    followingLabel.font = UIFont.systemFont(ofSize: 15.0)
    followingBG.addSubview(followingLabel)
    followingLabel.bottom(to: followingCountLabel)
    followingLabel.leftToRight(of: followingCountLabel, offset: 5.0)
    followingLabel.rightToSuperview()
    self.followingLabel = followingLabel
    
    //followerBG
    let followerBG = UIView()
    followerBG.isUserInteractionEnabled = true
    let followerTapGesture = UITapGestureRecognizer(target: self, action: #selector(followerTapped))
    followerBG.addGestureRecognizer(followerTapGesture)
    addSubview(followerBG)
    followerBG.topToBottom(of: nameLabel, offset: 10.0)
    followerBG.leftToRight(of: followingBG, offset: 20.0)
    self.followerBG = followerBG
    
    //followerCountLabel
    let followerCountLabel = UILabel()
    followerCountLabel.text = "0"
    followerCountLabel.textColor = ANIColor.dark
    followerCountLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
    followerBG.addSubview(followerCountLabel)
    followerCountLabel.edgesToSuperview(excluding: .right)
    self.followerCountLabel = followerCountLabel
    
    //followerLabel
    let followerLabel = UILabel()
    followerLabel.text = "フォロワー"
    followerLabel.textColor = ANIColor.subTitle
    followerLabel.font = UIFont.systemFont(ofSize: 15.0)
    followerBG.addSubview(followerLabel)
    followerLabel.bottom(to: followerCountLabel)
    followerLabel.leftToRight(of: followerCountLabel, offset: 5.0)
    followerLabel.rightToSuperview()
    self.followerLabel = followerLabel
    
    //groupLabel
    let groupLabel = UILabel()
    groupLabel.font = UIFont.systemFont(ofSize: 17.0)
    groupLabel.textAlignment = .center
    groupLabel.textColor = ANIColor.dark
    addSubview(groupLabel)
    groupLabel.topToBottom(of: followingBG, offset: 10.0)
    groupLabel.leftToSuperview(offset: 10.0)
    self.groupLabel = groupLabel
    
    //introduceBG
    let introduceBG = UIView()
    introduceBG.backgroundColor = ANIColor.bg
    introduceBG.layer.cornerRadius = 10.0
    introduceBG.layer.masksToBounds = true
    introduceBG.alpha = 0.0
    addSubview(introduceBG)
    introduceBG.topToBottom(of: groupLabel, offset: 10.0)
    introduceBG.leftToSuperview(offset: 10.0)
    introduceBG.rightToSuperview(offset: 10.0)
    introduceBG.bottomToSuperview(offset: -10.0)
    self.introduceBG = introduceBG
    
    //introductionLabel
    let introductionLabel = UILabel()
    groupLabel.font = UIFont.systemFont(ofSize: 17.0)
    introductionLabel.numberOfLines = 0
    introductionLabel.textColor = ANIColor.dark
    introduceBG.addSubview(introductionLabel)
    let insets = UIEdgeInsetsMake(10.0, 10.0, -10.0, -10.0)
    introductionLabel.edges(to: introduceBG, insets: insets)
    self.introductionLabel = introductionLabel
  }
  
  private func reloadLayout() {
    guard let nameLabel = self.nameLabel,
          let groupLabel = self.groupLabel,
          let introduceBG = self.introduceBG,
          let introductionLabel = self.introductionLabel,
          let user = self.user else { return }
    
    nameLabel.text = user.userName
    
    groupLabel.text = user.kind
    
    introductionLabel.text = user.introduce
    if let introduce = user.introduce {
      if introduce.count != 0 {
        introduceBG.alpha = 1.0
      } else {
        introduceBG.alpha = 0.0
      }
    } else {
      introduceBG.alpha = 0.0
    }
  }
  
  private func reloadFollowLayout() {
    guard let currentUserId = ANISessionManager.shared.currentUserUid,
          let followButton = self.followButton,
          let followLabel = self.followLabel,
          let followingCountLabel = self.followingCountLabel,
          let followerCountLabel = self.followerCountLabel else { return }
    
    if !followingUserIds.isEmpty {
      for id in followingUserIds.keys {
        if id == currentUserId {
          followButton.base?.backgroundColor = .clear
          followLabel.text = "フォロー中"
          followLabel.textColor = ANIColor.green
        } else {
          followButton.base?.backgroundColor = ANIColor.green
          followLabel.text = "フォロー"
          followLabel.textColor = .white
        }
      }
    } else {
      followButton.base?.backgroundColor = ANIColor.green
      followLabel.text = "フォロー"
      followLabel.textColor = .white
    }
    
    followerCountLabel.text = "\(followingUserIds.count)"
    followingCountLabel.text = "\(followUserIds.count)"
  }
  
  func observeUserFollow() {
    guard let userId = self.userId else { return }
    
    let databaseRef = Database.database().reference()
    
    databaseRef.child(KEY_USERS).child(userId).child(KEY_FOLLOW_USER_IDS).observe(.value) { (snapshot) in
      if let followUserIds = snapshot.value as? [String: String] {
        self.followUserIds = followUserIds
      } else {
        self.followUserIds.removeAll()
      }
    }
    
    databaseRef.child(KEY_USERS).child(userId).child(KEY_FOLLOWING_USER_IDS).observe(.value) { (snapshot) in
      if let followingUserIds = snapshot.value as? [String: String] {
        self.followingUserIds = followingUserIds
      } else {
        self.followingUserIds.removeAll()
      }
    }
  }
  
  private func isFollowed() {
    guard let user = self.user,
          let followingUserIds = user.followingUserIds,
          let currentUserId = ANISessionManager.shared.currentUserUid,
          let followButton = self.followButton,
          let followLabel = self.followLabel else { return }

    for id in followingUserIds.keys {
      if id == currentUserId {
        followButton.base?.backgroundColor = .clear
        followLabel.text = "フォロー中"
        followLabel.textColor = ANIColor.green
      } else {
        followButton.base?.backgroundColor = ANIColor.green
        followLabel.text = "フォロー"
        followLabel.textColor = .white
      }
    }
  }
  
  //MARK: action
  @objc private func followingTapped() {
    print("following tapped")
  }
  
  @objc private func followerTapped() {
    print("follower tapped")
  }
}

//MARK: ANIButtonViewDelegate
extension ANIOtherProfileCell: ANIButtonViewDelegate {
  func buttonViewTapped(view: ANIButtonView) {
    if view === self.followButton {
      guard let currentUserUid = ANISessionManager.shared.currentUserUid,
            let user = self.user,
            let userId = user.uid,
            let followButton = self.followButton else { return }
      
      let databaseRef = Database.database().reference()

      if followButton.base?.backgroundColor == ANIColor.green {
        DispatchQueue.global().async {
          let date = ANIFunction.shared.getToday()
          databaseRef.child(KEY_USERS).child(currentUserUid).child(KEY_FOLLOW_USER_IDS).updateChildValues([userId: date])
          databaseRef.child(KEY_USERS).child(userId).child(KEY_FOLLOWING_USER_IDS).updateChildValues([currentUserUid: date])
        }
      } else {
        DispatchQueue.global().async {
          databaseRef.child(KEY_USERS).child(currentUserUid).child(KEY_FOLLOW_USER_IDS).child(userId).removeValue()
          databaseRef.child(KEY_USERS).child(userId).child(KEY_FOLLOWING_USER_IDS).child(currentUserUid).removeValue()
        }
      }
    }
  }
}
