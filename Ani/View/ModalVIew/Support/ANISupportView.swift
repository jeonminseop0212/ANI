//
//  ANISuportView.swift
//  Ani
//
//  Created by jeonminseop on 2018/06/19.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import FirebaseDatabase
import CodableFirebase

protocol ANISupportViewDelegate {
  func supportButtonTapped()
}

class ANISupportView: UIView {
  
  private weak var titleLabel: UILabel?
  private weak var messageTextView: ANIPlaceHolderTextView?
  private let SUPPORT_BUTTON_HEIGHT: CGFloat = 40.0
  private weak var supportButton: ANIAreaButtonView?
  private weak var supportButtonLabel: UILabel?
  
  var recruit: FirebaseRecruit?
  
  var user: FirebaseUser?
  
  var delegate: ANISupportViewDelegate?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    //basic
    self.backgroundColor = .white
    self.layer.cornerRadius = 10.0
    self.layer.masksToBounds = true
    
    //titleLabel
    let titleLabel = UILabel()
    titleLabel.textColor = ANIColor.dark
    titleLabel.font = UIFont.boldSystemFont(ofSize: 19)
    titleLabel.text = "応援ありがとうございます😻"
    titleLabel.textAlignment = .center
    addSubview(titleLabel)
    titleLabel.topToSuperview(offset: 15.0)
    titleLabel.leftToSuperview(offset: 15.0)
    titleLabel.rightToSuperview(offset: 15.0)
    self.titleLabel = titleLabel
    
    //supportButton
    let supportButton = ANIAreaButtonView()
    supportButton.base?.backgroundColor = ANIColor.green
    supportButton.baseCornerRadius = SUPPORT_BUTTON_HEIGHT / 2
    supportButton.dropShadow(opacity: 0.1)
    supportButton.delegate = self
    addSubview(supportButton)
    supportButton.bottomToSuperview(offset: -10.0)
    supportButton.leftToSuperview(offset: 100.0)
    supportButton.rightToSuperview(offset: 100.0)
    supportButton.height(SUPPORT_BUTTON_HEIGHT)
    self.supportButton = supportButton
    
    //supportButtonLabel
    let supportButtonLabel = UILabel()
    supportButtonLabel.text = "応援する"
    supportButtonLabel.textAlignment = .center
    supportButtonLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
    supportButtonLabel.textColor = .white
    supportButton.addContent(supportButtonLabel)
    supportButtonLabel.edgesToSuperview()
    self.supportButtonLabel = supportButtonLabel
    
    //messageTextView
    let messageTextView = ANIPlaceHolderTextView()
    messageTextView.backgroundColor = ANIColor.bg
    messageTextView.layer.cornerRadius = 10.0
    messageTextView.layer.masksToBounds = true
    messageTextView.textColor = ANIColor.subTitle
    messageTextView.font = UIFont.systemFont(ofSize: 15.0)
    messageTextView.placeHolder = "応援メッセージを書きませんか？"
    addSubview(messageTextView)
    messageTextView.topToBottom(of: titleLabel, offset: 15.0)
    messageTextView.leftToSuperview(offset: 15.0)
    messageTextView.rightToSuperview(offset: 15.0)
    messageTextView.bottomToTop(of: supportButton, offset: -15.0)
    self.messageTextView = messageTextView
  }
  
  private func updateNoti(storyId: String) {
    guard let recruit = self.recruit,
          let currentUser = ANISessionManager.shared.currentUser,
          let currentUserName = currentUser.userName,
          let currentUserId = ANISessionManager.shared.currentUserUid,
          let user = self.user,
          let userId = user.uid,
          let messageTextView = self.messageTextView,
          let message = messageTextView.text else { return }
    
    let databaseRef = Database.database().reference()
    DispatchQueue.global().async {
      do {
        var noti = ""
        if message != "" {
          noti = "\(currentUserName)さんが「\(recruit.title)」募集を「応援」しました。\n\"\(message)\""
        } else {
          noti = "\(currentUserName)さんが「\(recruit.title)」募集を「応援」しました。"
        }
        let date = ANIFunction.shared.getToday()
        let notification = FirebaseNotification(userId: currentUserId, noti: noti, kind: KEY_NOTI_KIND_STROY, notiId: storyId, updateDate: date)
        if let data = try FirebaseEncoder().encode(notification) as? [String: AnyObject] {
          
          databaseRef.child(KEY_NOTIFICATIONS).child(userId).childByAutoId().updateChildValues(data)
        }
      } catch let error {
        print(error)
      }
    }
  }
}

//MARK: ANIButtonViewDelegate
extension ANISupportView: ANIButtonViewDelegate {
  func buttonViewTapped(view: ANIButtonView) {
    if view === supportButton {
      guard let recruit = self.recruit,
            let recruitId = recruit.id,
            let messageTextView = self.messageTextView,
            let uid = ANISessionManager.shared.currentUserUid else { return }
      
      let databaseRef = Database.database().reference()
      let databaseStoryRef = databaseRef.child(KEY_STORIES).childByAutoId()
      let id = databaseStoryRef.key
      let story = FirebaseStory(id: id, storyImageUrls: nil, story: messageTextView.text, userId: uid, loveIds: nil, commentIds: nil, recruitId: recruitId, recruitTitle: recruit.title, recruitSubTitle: recruit.reason)
      
      DispatchQueue.global().async {
        do {
          if let data = try FirebaseEncoder().encode(story) as? [String : AnyObject] {
            databaseStoryRef.updateChildValues(data)
          }
          
          if let id = story.id {
            let detabaseUsersRef = databaseRef.child(KEY_USERS).child(uid).child(KEY_POST_STORY_IDS)
            let value: [String: Bool] = [id: true]
            detabaseUsersRef.updateChildValues(value)
          }
        } catch let error {
          print(error)
        }
      }
      
      DispatchQueue.global().async {
        databaseRef.child(KEY_RECRUITS).child(recruitId).child(KEY_SUPPORT_RECRUIT_IDS).updateChildValues([uid: true])
      }
      
      updateNoti(storyId: id)
      
      self.delegate?.supportButtonTapped()
    }
  }
}
