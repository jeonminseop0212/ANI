//
//  ANIPopularUserCell.swift
//  Ani
//
//  Created by jeonminseop on 2019/02/16.
//  Copyright © 2019 JeonMinseop. All rights reserved.
//

import UIKit
import FirebaseFirestore
import TinyConstraints
import CodableFirebase

protocol ANIPopularUserCellDelegate {
  func reject()
}

class ANIPopularUserCell: UICollectionViewCell {
  
  private weak var base: UIView?
  private let PROFILE_IMAGE_VIEW_HEIGHT: CGFloat = 60.0
  private weak var profileImageView: UIImageView?
  private weak var userNameLabel: UILabel?
  private weak var introduceLabel: UILabel?
  private let FOLLOW_BUTTON_HEIGHT: CGFloat = 30.0
  private var followButtonHeightConstraint: Constraint?
  private var followButtonBottomConstraint: Constraint?
  private weak var followButton: ANIAreaButtonView?
  private weak var followLabel: UILabel?
  
  var user: FirebaseUser? {
    didSet {
      reloadLayout()
      checkFollowed()
      reloadFollowButtonLayout()
    }
  }
  
  var delegate: ANIPopularUserCellDelegate?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    self.backgroundColor = ANIColor.bg
    self.isUserInteractionEnabled = true
    self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileImageViewTapped)))
    
    //base
    let base = UIView()
    base.backgroundColor = .white
    base.layer.cornerRadius = 10.0
    base.layer.masksToBounds = true
    self.addSubview(base)
    base.edgesToSuperview()
    self.base = base
    
    //profileImageView
    let profileImageView = UIImageView()
    profileImageView.backgroundColor = ANIColor.gray
    profileImageView.layer.cornerRadius = PROFILE_IMAGE_VIEW_HEIGHT / 2
    profileImageView.layer.masksToBounds = true
    base.addSubview(profileImageView)
    profileImageView.topToSuperview(offset: 10.0)
    profileImageView.centerXToSuperview()
    profileImageView.width(PROFILE_IMAGE_VIEW_HEIGHT)
    profileImageView.height(PROFILE_IMAGE_VIEW_HEIGHT)
    self.profileImageView = profileImageView
    
    //userNameLabel
    let userNameLabel = UILabel()
    userNameLabel.textColor = ANIColor.dark
    userNameLabel.font = UIFont.boldSystemFont(ofSize: 15.0)
    userNameLabel.textAlignment = .center
    userNameLabel.numberOfLines = 2
    base.addSubview(userNameLabel)
    userNameLabel.topToBottom(of: profileImageView, offset: 10.0)
    userNameLabel.leftToSuperview(offset: 10.0)
    userNameLabel.rightToSuperview(offset: -10.0)
    userNameLabel.height(40.0)
    self.userNameLabel = userNameLabel
    
    //followButton
    let followButton = ANIAreaButtonView()
    followButton.baseCornerRadius = FOLLOW_BUTTON_HEIGHT / 2
    followButton.base?.backgroundColor = ANIColor.emerald
    followButton.base?.layer.borderWidth = 1.8
    followButton.base?.layer.borderColor = ANIColor.emerald.cgColor
    followButton.delegate = self
    base.addSubview(followButton)
    followButton.centerXToSuperview()
    followButton.width(100.0)
    followButtonHeightConstraint = followButton.height(FOLLOW_BUTTON_HEIGHT)
    followButtonBottomConstraint = followButton.bottomToSuperview(offset: -10.0)
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
    
    //introduceLabel
    let introduceLabel = UILabel()
    introduceLabel.textColor = ANIColor.subTitle
    introduceLabel.font = UIFont.systemFont(ofSize: 14.0)
    introduceLabel.textAlignment = .center
    introduceLabel.numberOfLines = 0
    base.addSubview(introduceLabel)
    introduceLabel.topToBottom(of: userNameLabel, offset: 10.0)
    introduceLabel.leftToSuperview(offset: 10.0)
    introduceLabel.rightToSuperview(offset: -10.0)
    introduceLabel.bottomToTop(of: followButton, offset: -10.0)
    self.introduceLabel = introduceLabel
  }
  
  private func reloadLayout() {
    guard let user = self.user,
          let profileImageView = self.profileImageView,
          let userNameLabel = self.userNameLabel,
          let introduceLabel = self.introduceLabel else { return }
    
    if let profileImageUrl = user.profileImageUrl {
      profileImageView.sd_setImage(with: URL(string: profileImageUrl), completed: nil)
    } else {
      profileImageView.image = UIImage()
    }
    
    if let userName = user.userName {
      userNameLabel.text = userName
    } else {
      userNameLabel.text = ""
    }
    
    if let introduce = user.introduce {
      introduceLabel.text = introduce
    } else {
      introduceLabel.text = ""
    }
  }
  
  private func checkFollowed() {
    guard let user = self.user,
          let userId = user.uid,
          let followButton = self.followButton,
          let followLabel = self.followLabel else { return }
    
    if let currentUserId = ANISessionManager.shared.currentUserUid {
      let database = Firestore.firestore()
      
      DispatchQueue.global().async {
        database.collection(KEY_USERS).document(currentUserId).collection(KEY_FOLLOWING_USER_IDS).getDocuments(completion: { (snapshot, error) in
          if let error = error {
            DLog("Error get document: \(error)")
            
            return
          }
          
          guard let snapshot = snapshot else { return }
          
          for document in snapshot.documents {
            if document.documentID == userId {
              followButton.base?.backgroundColor = .clear
              followLabel.text = "フォロー中"
              followLabel.textColor = ANIColor.emerald
              
              break
            } else {
              followButton.base?.backgroundColor = ANIColor.emerald
              followLabel.text = "フォロー"
              followLabel.textColor = .white
            }
          }
          
          if snapshot.documents.isEmpty {
            followButton.base?.backgroundColor = ANIColor.emerald
            followLabel.text = "フォロー"
            followLabel.textColor = .white
          }
          
          DispatchQueue.main.async {
            UIView.animate(withDuration: 0.1, animations: {
              followButton.alpha = 1.0
            })
          }
        })
      }
    } else {
      followButton.base?.backgroundColor = ANIColor.emerald
      followLabel.text = "フォロー"
      followLabel.textColor = .white
      
      UIView.animate(withDuration: 0.1, animations: {
        followButton.alpha = 1.0
      })
    }
  }
  
  private func reloadFollowButtonLayout() {
    guard let user = self.user,
          let currentUserUid = ANISessionManager.shared.currentUserUid,
          let followButtonHeightConstraint = self.followButtonHeightConstraint,
          let followButtonBottomConstraint = self.followButtonBottomConstraint else { return }
    
    if user.uid == currentUserUid {
      followButtonHeightConstraint.constant = 0.0
      followButtonBottomConstraint.constant = 0.0
    } else {
      followButtonHeightConstraint.constant = FOLLOW_BUTTON_HEIGHT
      followButtonBottomConstraint.constant = -10.0
    }
  }
  
  private func updateNoti() {
    guard let currentUser = ANISessionManager.shared.currentUser,
          let currentUserName = currentUser.userName,
          let currentUserId = ANISessionManager.shared.currentUserUid,
          let user = self.user,
          let userId = user.uid,
          currentUserId != userId else { return }
    
    let database = Firestore.firestore()
    
    DispatchQueue.global().async {
      do {
        let noti = "\(currentUserName)さんがあなたをフォローしました。"
        let date = ANIFunction.shared.getToday()
        let notification = FirebaseNotification(userId: currentUserId, userName: currentUserName, noti: noti, contributionKind: KEY_CONTRIBUTION_KIND_USER, notiKind: KEY_NOTI_KIND_FOLLOW, notiId: currentUserId, commentId: nil, updateDate: date)
        let data = try FirestoreEncoder().encode(notification)
        
        database.collection(KEY_USERS).document(userId).collection(KEY_NOTIFICATIONS).document(currentUserId).setData(data)
        database.collection(KEY_USERS).document(userId).updateData([KEY_IS_HAVE_UNREAD_NOTI: true])
      } catch let error {
        DLog(error)
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
extension ANIPopularUserCell: ANIButtonViewDelegate {
  func buttonViewTapped(view: ANIButtonView) {
    if view === followButton {
      guard let user = self.user,
            let userId = user.uid,
            let followButton = self.followButton,
            let followLabel = self.followLabel else { return }
      
      if let currentUserUid = ANISessionManager.shared.currentUserUid, !ANISessionManager.shared.isAnonymous {
        let database = Firestore.firestore()
        
        if followButton.base?.backgroundColor == ANIColor.emerald {
          DispatchQueue.global().async {
            let date = ANIFunction.shared.getToday()
            database.collection(KEY_USERS).document(currentUserUid).collection(KEY_FOLLOWING_USER_IDS).document(userId).setData([KEY_DATE: date])
            database.collection(KEY_USERS).document(userId).collection(KEY_FOLLOWER_IDS).document(currentUserUid).setData([KEY_DATE: date])
            
            self.updateNoti()
            ANIFunction.shared.showReviewAlertFollow()
          }
          
          followButton.base?.backgroundColor = .clear
          followLabel.text = "フォロー中"
          followLabel.textColor = ANIColor.emerald
        } else {
          DispatchQueue.global().async {
            database.collection(KEY_USERS).document(currentUserUid).collection(KEY_FOLLOWING_USER_IDS).document(userId).delete()
            database.collection(KEY_USERS).document(userId).collection(KEY_FOLLOWER_IDS).document(currentUserUid).delete()
          }
          
          followButton.base?.backgroundColor = ANIColor.emerald
          followLabel.text = "フォロー"
          followLabel.textColor = .white
        }
      } else {
        self.delegate?.reject()
      }
    }
  }
}
