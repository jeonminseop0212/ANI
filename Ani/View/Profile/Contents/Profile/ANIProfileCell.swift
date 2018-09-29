//
//  profileTableViewCell.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/18.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import FirebaseFirestore

protocol ANIProfileCellDelegate {
  func followingTapped()
  func followerTapped()
}

class ANIProfileCell: UITableViewCell {
  
  private weak var nameLabel: UILabel?
  private let PROFILE_EDIT_BUTTON_HEIGHT: CGFloat = 30.0
  private weak var profileEditButton: ANIAreaButtonView?
  private weak var profileEditLabel: UILabel?
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
    }
  }
  
  var followListener: ListenerRegistration?
  
  var delegate: ANIProfileCellDelegate?
    
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
    setupNotifications()
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
    profileEditButton.rightToSuperview(offset: -10.0)
    profileEditButton.width(60.0)
    profileEditButton.height(PROFILE_EDIT_BUTTON_HEIGHT)
    self.profileEditButton = profileEditButton
    
    //profileEditLabel
    let profileEditLabel = UILabel()
    profileEditLabel.textColor = .white
    profileEditLabel.text = "更新"
    profileEditLabel.textAlignment = .center
    profileEditLabel.font = UIFont.boldSystemFont(ofSize: 15)
    profileEditButton.addContent(profileEditLabel)
    profileEditLabel.edgesToSuperview()
    self.profileEditLabel = profileEditLabel
    
    //nameLabel
    let nameLabel = UILabel()
    nameLabel.font = UIFont.boldSystemFont(ofSize: 19.0)
    nameLabel.textColor = ANIColor.dark
    nameLabel.numberOfLines = 0
    addSubview(nameLabel)
    nameLabel.topToSuperview(offset: 10.0)
    nameLabel.leftToSuperview(offset: 10.0)
    nameLabel.rightToLeft(of: profileEditButton, offset: -10.0)
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
    introduceBG.rightToSuperview(offset: -10.0)
    introduceBG.bottomToSuperview(offset: -10.0)
    self.introduceBG = introduceBG

    //introductionLabel
    let introductionLabel = UILabel()
    groupLabel.font = UIFont.systemFont(ofSize: 17.0)
    introductionLabel.numberOfLines = 0
    introductionLabel.textColor = ANIColor.dark
    introduceBG.addSubview(introductionLabel)
    let insets = UIEdgeInsets.init(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    introductionLabel.edgesToSuperview(insets: insets)
    self.introductionLabel = introductionLabel
  }
  
  @objc private func reloadLayout() {
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
    
    observeFollow()
  }
  
  private func observeFollow() {
    guard let currentUserId = ANISessionManager.shared.currentUserUid else { return }

    followListener?.remove()
    
    let database = Firestore.firestore()
    
    DispatchQueue.global().async {
      self.followListener = database.collection(KEY_USERS).document(currentUserId).collection(KEY_FOLLOWING_USER_IDS).addSnapshotListener({ (snapshot, error) in
        if let error = error {
          DLog("Error get document: \(error)")
          
          return
        }
        
        guard let snapshot = snapshot, let followingCountLabel = self.followingCountLabel else { return }
        
        followingCountLabel.text = "\(snapshot.documents.count)"
      })
      
      database.collection(KEY_USERS).document(currentUserId).collection(KEY_FOLLOWER_IDS).addSnapshotListener({ (snapshot, error) in
        if let error = error {
          DLog("Error get document: \(error)")
          
          return
        }
        
        guard let snapshot = snapshot, let followerCountLabel = self.followerCountLabel else { return }
        
        followerCountLabel.text = "\(snapshot.documents.count)"
      })
    }
  }
  
  private func setupNotifications() {
    ANINotificationManager.receive(login: self, selector: #selector(reloadLayout))
  }
  
  //MARK: action
  @objc private func followingTapped() {
    self.delegate?.followingTapped()
  }
  
  @objc private func followerTapped() {
    self.delegate?.followerTapped()
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
