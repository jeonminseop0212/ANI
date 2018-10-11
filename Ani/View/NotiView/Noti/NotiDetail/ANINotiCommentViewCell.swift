//
//  ANINotiCommentViewCell.swift
//  Ani
//
//  Created by jeonminseop on 2018/07/10.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import WCLShineButton
import FirebaseFirestore
import CodableFirebase

class ANINotiCommentViewCell: UITableViewCell {
  
  private weak var base: UIView?
  private weak var commentLabel: UILabel?
  
  private let PROFILE_IMAGE_VIEW_HEIGHT: CGFloat = 25.0
  private weak var profileImageView: UIImageView?
  private weak var userNameLabel: UILabel?
  
//  private weak var loveButton: WCLShineButton?
//  private weak var loveCountLabel: UILabel?
//  private weak var commentButton: UIButton?
//  private weak var commentCountLabel: UILabel?
  
  var comment: FirebaseComment? {
    didSet {
      reloadLayout()
      loadUser()
    }
  }
  
  private var user: FirebaseUser?
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    //basic
    self.selectionStyle = .none
    self.backgroundColor = ANIColor.bg
    
    //base
    let base = UIView()
    base.backgroundColor = .white
    addSubview(base)
    base.edgesToSuperview()
    self.base = base
    
    //commentLabel
    let commentLabel = UILabel()
    commentLabel.textColor = ANIColor.dark
    commentLabel.font = UIFont.systemFont(ofSize: 15.0)
    commentLabel.numberOfLines = 0
    base.addSubview(commentLabel)
    let insets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    commentLabel.edgesToSuperview(excluding: .bottom, insets: insets)
    self.commentLabel = commentLabel
    
    //profileImageView
    let profileImageView = UIImageView()
    profileImageView.backgroundColor = ANIColor.gray
    profileImageView.layer.cornerRadius = PROFILE_IMAGE_VIEW_HEIGHT / 2
    profileImageView.layer.masksToBounds = true
    profileImageView.isUserInteractionEnabled = true
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageViewTapped))
    profileImageView.addGestureRecognizer(tapGesture)
    base.addSubview(profileImageView)
    profileImageView.width(PROFILE_IMAGE_VIEW_HEIGHT)
    profileImageView.height(PROFILE_IMAGE_VIEW_HEIGHT)
    profileImageView.topToBottom(of: commentLabel, offset: 10.0)
    profileImageView.leftToSuperview(offset: 10.0)
    profileImageView.bottomToSuperview(offset: -10.0)
    self.profileImageView = profileImageView
    
//    //commentCountLabel
//    let commentCountLabel = UILabel()
//    commentCountLabel.textColor = ANIColor.dark
//    commentCountLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
//    base.addSubview(commentCountLabel)
//    commentCountLabel.centerY(to: profileImageView)
//    commentCountLabel.rightToSuperview(offset: 10.0)
//    commentCountLabel.width(20.0)
//    commentCountLabel.height(15.0)
//    self.commentCountLabel = commentCountLabel
//
//    //commentButton
//    let commentButton = UIButton()
//    commentButton.setImage(UIImage(named: "comment"), for: .normal)
//    base.addSubview(commentButton)
//    commentButton.centerY(to: profileImageView)
//    commentButton.rightToLeft(of: commentCountLabel, offset: -10.0)
//    commentButton.width(15.0)
//    commentButton.height(15.0)
//    self.commentButton = commentButton
//
//    //loveCountLabel
//    let loveCountLabel = UILabel()
//    loveCountLabel.textColor = ANIColor.dark
//    loveCountLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
//    base.addSubview(loveCountLabel)
//    loveCountLabel.centerY(to: profileImageView)
//    loveCountLabel.rightToLeft(of: commentButton, offset: -10.0)
//    loveCountLabel.width(20.0)
//    loveCountLabel.height(15.0)
//    self.loveCountLabel = loveCountLabel
//
//    //loveButton
//    var param = WCLShineParams()
//    param.bigShineColor = ANIColor.pink
//    param.smallShineColor = ANIColor.lightPink
//    let loveButton = WCLShineButton(frame: CGRect(x: 0.0, y: 0.0, width: 15.0, height: 15.0), params: param)
//    loveButton.fillColor = ANIColor.pink
//    loveButton.color = ANIColor.gray
//    loveButton.image = .heart
//    loveButton.addTarget(self, action: #selector(love), for: .valueChanged)
//    base.addSubview(loveButton)
//    loveButton.centerY(to: profileImageView)
//    loveButton.rightToLeft(of: loveCountLabel, offset: -10.0)
//    loveButton.width(15.0)
//    loveButton.height(15.0)
//    self.loveButton = loveButton
    
    //userNameLabel
    let userNameLabel = UILabel()
    userNameLabel.textColor = ANIColor.dark
    userNameLabel.font = UIFont.boldSystemFont(ofSize: 15.0)
    userNameLabel.numberOfLines = 0
    base.addSubview(userNameLabel)
    userNameLabel.leftToRight(of: profileImageView, offset: 10.0)
    userNameLabel.rightToSuperview(offset: -10.0)
//    userNameLabel.rightToLeft(of: loveButton, offset: -10.0)
    userNameLabel.centerY(to: profileImageView)
    self.userNameLabel = userNameLabel
  }
  
  private func reloadLayout() {
    guard let commentLabel = self.commentLabel,
//          let commentCountLabel = self.commentCountLabel,
//          let loveCountLabel = self.loveCountLabel,
          let comment = self.comment else { return }
    
    commentLabel.text = comment.comment
//    commentCountLabel.text = "\(comment.commentCount)"
//    loveCountLabel.text = "\(comment.loveCount)"
  }
  
  private func reloadUserLayout(user: FirebaseUser) {
    guard let userNameLabel = self.userNameLabel,
          let profileImageView = self.profileImageView,
          let profileImageUrl = user.profileImageUrl,
          let userName = user.userName else { return }
    
    profileImageView.sd_setImage(with: URL(string: profileImageUrl), completed: nil)
    userNameLabel.text = userName
  }
  
  //MARK: action
  @objc private func love() {
    DLog("love")
  }
  
  @objc private func profileImageViewTapped() {
    guard let comment = self.comment else { return }
    
    ANINotificationManager.postProfileImageViewTapped(userId: comment.userId)
  }
}

//MARK: data
extension ANINotiCommentViewCell {
  private func loadUser() {
    guard let comment = self.comment else { return }
    
    let database = Firestore.firestore()
    
    DispatchQueue.global().async {
      database.collection(KEY_USERS).document(comment.userId).getDocument(completion: { (snapshot, error) in
        if let error = error {
          DLog("Error get document: \(error)")
          
          return
        }
        
        guard let snapshot = snapshot, let data = snapshot.data() else { return }
        
        do {
          let user = try FirebaseDecoder().decode(FirebaseUser.self, from: data)
          self.user = user
          
          DispatchQueue.main.async {
            self.reloadUserLayout(user: user)
          }
        } catch let error {
          DLog(error)
        }
      })
    }
  }
}
