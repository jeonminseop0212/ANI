//
//  ANINotiViewCell.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/15.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import FirebaseDatabase
import CodableFirebase

class ANIBasicNotiViewCell: UITableViewCell {
  
  private let PROFILE_IMAGE_VIEW_HEIGHT: CGFloat = 50.0
  private weak var profileImageView: UIImageView?
  private weak var notiLabel: UILabel?
  
  var noti: FirebaseNotification? {
    didSet {
      loadUser()
      reloadLayout()
    }
  }
  
  private var user: FirebaseUser? {
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
    backgroundColor = .white
    
    //profileImageView
    let profileImageView = UIImageView()
    profileImageView.backgroundColor = ANIColor.bg
    profileImageView.layer.cornerRadius = PROFILE_IMAGE_VIEW_HEIGHT / 2
    profileImageView.layer.masksToBounds = true
    profileImageView.isUserInteractionEnabled = true
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageViewTapped))
    profileImageView.addGestureRecognizer(tapGesture)
    addSubview(profileImageView)
    profileImageView.topToSuperview(offset: 10.0)
    profileImageView.leftToSuperview(offset: 10.0)
    profileImageView.width(PROFILE_IMAGE_VIEW_HEIGHT)
    profileImageView.height(PROFILE_IMAGE_VIEW_HEIGHT)
    self.profileImageView = profileImageView

    //notiLabel
    let notiLabel = UILabel()
    notiLabel.numberOfLines = 0
    notiLabel.font = UIFont.systemFont(ofSize: 14.0)
    notiLabel.textColor = ANIColor.subTitle
    addSubview(notiLabel)
    notiLabel.topToSuperview(offset: 10.0)
    notiLabel.leftToRight(of: profileImageView, offset: 10.0)
    notiLabel.rightToSuperview(offset: 10.0)
    self.notiLabel = notiLabel
    
    //bottomSpace
    let spaceView = UIView()
    spaceView.backgroundColor = ANIColor.bg
    addSubview(spaceView)
    spaceView.topToBottom(of: profileImageView, offset: 10)
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
  
  @objc private func profileImageViewTapped() {
    guard let noti = self.noti else { return }
    
    ANINotificationManager.postProfileImageViewTapped(userId: noti.userId)
  }
}

//MARK: data
extension ANIBasicNotiViewCell {
  func loadUser() {
    guard let noti = self.noti else { return }
    
    DispatchQueue.global().async {
      let databaseRef = Database.database().reference()
      databaseRef.child(KEY_USERS).child(noti.userId).observeSingleEvent(of: .value, with: { (userSnapshot) in
        if let userValue = userSnapshot.value {
          do {
            let user = try FirebaseDecoder().decode(FirebaseUser.self, from: userValue)
            self.user = user
          } catch let error {
            print(error)
          }
        }
      })
    }
  }
}
