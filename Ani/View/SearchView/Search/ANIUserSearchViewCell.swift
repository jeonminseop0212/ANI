//
//  ANIUserSearchViewCell.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/16.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import FirebaseDatabase
import CodableFirebase

class ANIUserSearchViewCell: UITableViewCell {
  
  private weak var stackView: UIStackView?
  private let PROFILE_IMAGE_VIEW_HEIGHT: CGFloat = 50.0
  private weak var profileImageView: UIImageView?
  private weak var userNameLabel: UILabel?
  private weak var followButton: ANIAreaButtonView?
  private weak var followLabel: UILabel?
  
  var user: FirebaseUser? {
    didSet {
      reloadLayout()
      checkFollowed()
      reloadFollowButtonLayout()
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
    profileImageView.isUserInteractionEnabled = true
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageViewTapped))
    profileImageView.addGestureRecognizer(tapGesture)
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
    followButton.alpha = 0.0
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
  
  private func reloadLayout() {
    guard let profileImageView = self.profileImageView,
          let userNameLabel = self.userNameLabel,
          let user = self.user,
          let profileImageUrl = user.profileImageUrl else { return }
    
    profileImageView.sd_setImage(with: URL(string: profileImageUrl), completed: nil)
    userNameLabel.text = user.userName
  }
  
  private func reloadFollowButtonLayout() {
    guard let user = self.user,
          let currentUserUid = ANISessionManager.shared.currentUserUid,
          let followButton = self.followButton else { return }
    
    if user.uid == currentUserUid {
      followButton.isHidden = true
    } else {
      followButton.isHidden = false
    }
  }
  
  private func checkFollowed() {
    guard let user = self.user,
          let userId = user.uid,
          let currentUserId = ANISessionManager.shared.currentUserUid,
          let followButton = self.followButton,
          let followLabel = self.followLabel else { return }
    
    let databaseRef = Database.database().reference()
    
    DispatchQueue.global().async {
      databaseRef.child(KEY_FOLLOWING_USER_IDS).child(currentUserId).observeSingleEvent(of: .value) { (snapshot) in
        guard let followingUser = snapshot.value as? [String: String] else { return }
        
        for id in followingUser.keys {
          if id == userId {
            followButton.base?.backgroundColor = .clear
            followLabel.text = "フォロー中"
            followLabel.textColor = ANIColor.green
            
            break
          } else {
            followButton.base?.backgroundColor = ANIColor.green
            followLabel.text = "フォロー"
            followLabel.textColor = .white
          }
        }
        
        DispatchQueue.main.async {
          UIView.animate(withDuration: 0.1, animations: {
            followButton.alpha = 1.0
          })
        }
      }
    }
  }
  
  private func updateNoti() {
    guard let currentUser = ANISessionManager.shared.currentUser,
          let currentUserName = currentUser.userName,
          let currentUserId = ANISessionManager.shared.currentUserUid,
          let user = self.user,
          let userId = user.uid else { return }
    
    let databaseRef = Database.database().reference()
    
    DispatchQueue.global().async {
      do {
        let noti = "\(currentUserName)さんがあなたをフォローしました。"
        let date = ANIFunction.shared.getToday()
        let notification = FirebaseNotification(userId: currentUserId, noti: noti, kind: KEY_NOTI_KIND_FOLLOW, notiId: userId, commentId: nil, updateDate: date)
        if let data = try FirebaseEncoder().encode(notification) as? [String: AnyObject] {
          databaseRef.child(KEY_NOTIFICATIONS).child(userId).child(currentUserId).updateChildValues(data)
        }
      } catch let error {
        print(error)
      }
    }
  }
  
  //MARK: action
  @objc private func profileImageViewTapped() {
    guard let user = self.user,
          let userId = user.uid else { return }
    
    ANINotificationManager.postProfileImageViewTapped(userId: userId)
  }
}

//MARK: ANIButtonViewDelegate
extension ANIUserSearchViewCell: ANIButtonViewDelegate {
  func buttonViewTapped(view: ANIButtonView) {
    if view === followButton {
      guard let currentUserUid = ANISessionManager.shared.currentUserUid,
            let user = self.user,
            let userId = user.uid,
            let followButton = self.followButton,
            let followLabel = self.followLabel else { return }
      
      let databaseRef = Database.database().reference()
      
      if followButton.base?.backgroundColor == ANIColor.green {
        DispatchQueue.global().async {
          let date = ANIFunction.shared.getToday()
          databaseRef.child(KEY_FOLLOWING_USER_IDS).child(currentUserUid).updateChildValues([userId: date])
          databaseRef.child(KEY_FOLLOWER_IDS).child(userId).updateChildValues([currentUserUid: date])
          
          self.updateNoti()
        }
        
        followButton.base?.backgroundColor = .clear
        followLabel.text = "フォロー中"
        followLabel.textColor = ANIColor.green
      } else {
        DispatchQueue.global().async {
          databaseRef.child(KEY_FOLLOWING_USER_IDS).child(currentUserUid).child(userId).removeValue()
          databaseRef.child(KEY_FOLLOWER_IDS).child(userId).child(currentUserUid).removeValue()
        }
        
        followButton.base?.backgroundColor = ANIColor.green
        followLabel.text = "フォロー"
        followLabel.textColor = .white
      }
    }
  }
}
