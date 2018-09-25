//
//  ANIFollowNotiViewCell.swift
//  Ani
//
//  Created by jeonminseop on 2018/07/09.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import FirebaseFirestore
import CodableFirebase

protocol ANIFollowNotiViewCellDelegate {
  func loadedNotiUser(user: FirebaseUser)
}

class ANIFollowNotiViewCell: UITableViewCell {
  
  private weak var stackView: UIStackView?
  private let PROFILE_IMAGE_VIEW_HEIGHT: CGFloat = 50.0
  private weak var profileImageView: UIImageView?
  private weak var notiLabel: UILabel?
  
  private weak var followButton: ANIAreaButtonView?
  private weak var followLabel: UILabel?
  
  var noti: FirebaseNotification? {
    didSet {
      if user == nil {
        loadUser()
      }
      reloadLayout()
    }
  }
  
  var user: FirebaseUser? {
    didSet {
      checkFollowed()
      reloadUserLayout()
    }
  }
  
  var delegate: ANIFollowNotiViewCellDelegate?
  
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
    
    //stackView
    let stackView = UIStackView()
    stackView.alignment = .top
    stackView.axis = .horizontal
    stackView.spacing = 10.0
    addSubview(stackView)
    stackView.topToSuperview(offset: 10.0)
    stackView.leftToSuperview(offset: 10.0)
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
    
    //notiLabel
    let notiLabel = UILabel()
    notiLabel.textColor = ANIColor.dark
    notiLabel.numberOfLines = 0
    notiLabel.font = UIFont.systemFont(ofSize: 14.0)
    notiLabel.textColor = ANIColor.subTitle
    stackView.addArrangedSubview(notiLabel)
    self.notiLabel = notiLabel
    
    //followButton
    let followButton = ANIAreaButtonView()
    followButton.baseCornerRadius = 10.0
    followButton.base?.backgroundColor = ANIColor.green
    followButton.base?.layer.borderWidth = 1.8
    followButton.base?.layer.borderColor = ANIColor.green.cgColor
    followButton.alpha = 0.0
    followButton.delegate = self
    addSubview(followButton)
    followButton.centerY(to: profileImageView)
    followButton.leftToRight(of: stackView, offset: 10.0)
    followButton.rightToSuperview(offset: 10.0)
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
    
    //bottomSpace
    let spaceView = UIView()
    spaceView.backgroundColor = ANIColor.bg
    addSubview(spaceView)
    spaceView.topToBottom(of: stackView, offset: 10)
    spaceView.leftToSuperview()
    spaceView.rightToSuperview()
    spaceView.height(10.0)
    spaceView.bottomToSuperview()
  }
  
  private func reloadLayout() {
    guard let notiLabel = self.notiLabel,
          let noti = self.noti else { return }
    
    notiLabel.text = noti.noti
  }
  
  private func reloadUserLayout() {
    guard let profileImageView = self.profileImageView,
          let user = self.user,
          let profileImageUrl = user.profileImageUrl else { return }
    
    profileImageView.sd_setImage(with: URL(string: profileImageUrl), completed: nil)
  }
  
  @objc private func cellTapped() {
    guard let noti = self.noti else { return }
    
    ANINotificationManager.postProfileImageViewTapped(userId: noti.userId)
  }
  
  private func checkFollowed() {
    guard let user = self.user,
          let userId = user.uid,
          let currentUserId = ANISessionManager.shared.currentUserUid,
          let followButton = self.followButton,
          let followLabel = self.followLabel else { return }
    
    let database = Firestore.firestore()
    
    DispatchQueue.global().async {
      database.collection(KEY_USERS).document(currentUserId).collection(KEY_FOLLOWING_USER_IDS).getDocuments(completion: { (snapshot, error) in
        if let error = error {
          print("Error get document: \(error)")
          
          return
        }
        
        guard let snapshot = snapshot else { return }
        
        for document in snapshot.documents {
          if document.documentID == userId {
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
        
        if snapshot.documents.isEmpty {
          followButton.base?.backgroundColor = ANIColor.green
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
        let notification = FirebaseNotification(userId: currentUserId, noti: noti, contributionKind: KEY_CONTRIBUTION_KIND_USER, notiKind: KEY_NOTI_KIND_FOLLOW, notiId: userId, commentId: nil, updateDate: date)
        let data = try FirestoreEncoder().encode(notification)
        
        database.collection(KEY_USERS).document(userId).collection(KEY_NOTIFICATIONS).document(currentUserId).setData(data)
      } catch let error {
        print(error)
      }
    }
  }
}

//MARK: ANIButtonViewDelegate
extension ANIFollowNotiViewCell: ANIButtonViewDelegate {
  func buttonViewTapped(view: ANIButtonView) {
    if view === followButton {
      guard let currentUserUid = ANISessionManager.shared.currentUserUid,
            let user = self.user,
            let userId = user.uid,
            let followButton = self.followButton,
            let followLabel = self.followLabel else { return }
      
      let database = Firestore.firestore()
      
      if followButton.base?.backgroundColor == ANIColor.green {
        DispatchQueue.global().async {
          let date = ANIFunction.shared.getToday()
          database.collection(KEY_USERS).document(currentUserUid).collection(KEY_FOLLOWING_USER_IDS).document(userId).setData([KEY_DATE: date])
          database.collection(KEY_USERS).document(userId).collection(KEY_FOLLOWER_IDS).document(currentUserUid).setData([KEY_DATE: date])
          
          self.updateNoti()
        }
        
        followButton.base?.backgroundColor = .clear
        followLabel.text = "フォロー中"
        followLabel.textColor = ANIColor.green
      } else {
        DispatchQueue.global().async {
          database.collection(KEY_USERS).document(currentUserUid).collection(KEY_FOLLOWING_USER_IDS).document(userId).delete()
          database.collection(KEY_USERS).document(userId).collection(KEY_FOLLOWER_IDS).document(currentUserUid).delete()
        }
        
        followButton.base?.backgroundColor = ANIColor.green
        followLabel.text = "フォロー"
        followLabel.textColor = .white
      }
    }
  }
}

//MARK: data
extension ANIFollowNotiViewCell {
  func loadUser() {
    guard let noti = self.noti else { return }
    
    let database = Firestore.firestore()
    
    DispatchQueue.global().async {
      database.collection(KEY_USERS).document(noti.userId).getDocument(completion: { (snapshot, error) in
        if let error = error {
          print("Error get document: \(error)")
          
          return
        }
        
        guard let snapshot = snapshot, let data = snapshot.data() else { return }
        
        do {
          let user = try FirebaseDecoder().decode(FirebaseUser.self, from: data)
          self.user = user
          self.delegate?.loadedNotiUser(user: user)
        } catch let error {
          print(error)
        }
      })
    }
  }
}
