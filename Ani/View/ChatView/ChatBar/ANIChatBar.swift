//
//  ChatBar.swift
//  Ani
//
//  Created by jeonminseop on 2018/06/28.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import GrowingTextView
import FirebaseFirestore
import CodableFirebase

class ANIChatBar: UIView {
  
  private weak var profileImageView: UIImageView?
  
  private weak var chatTextViewBG: UIView?
  private weak var chatTextView: GrowingTextView?
  
  private weak var postMessageButton: UIButton?
  
  var chatGroupId: String?
  
  var user: FirebaseUser?
  
  var isHaveGroup: Bool = false
  
  var messages = [FirebaseChatMessage]()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setup()
    setProfileImage()
    setupNotifications()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    //profileImageView
    let profileImageView = UIImageView()
    profileImageView.backgroundColor = ANIColor.gray
    profileImageView.layer.cornerRadius = 40.0 / 2
    profileImageView.layer.masksToBounds = true
    profileImageView.contentMode = .scaleAspectFill
    addSubview(profileImageView)
    profileImageView.width(40.0)
    profileImageView.height(40.0)
    profileImageView.bottomToSuperview(offset: -10.0)
    profileImageView.leftToSuperview(offset: 10.0)
    self.profileImageView = profileImageView
    
    //chatTextViewBG
    let chatTextViewBG = UIView()
    chatTextViewBG.layer.cornerRadius = profileImageView.layer.cornerRadius
    chatTextViewBG.layer.masksToBounds = true
    chatTextViewBG.layer.borderColor = ANIColor.gray.cgColor
    chatTextViewBG.layer.borderWidth = 1.0
    addSubview(chatTextViewBG)
    let bgInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    chatTextViewBG.leftToRight(of: profileImageView, offset: 10.0)
    chatTextViewBG.edgesToSuperview(excluding: .left, insets: bgInsets)
    self.chatTextViewBG = chatTextViewBG
    
    //postMessageButton
    let postMessageButton = UIButton()
    postMessageButton.setTitle("送信する", for: .normal)
    postMessageButton.setTitleColor(ANIColor.emerald, for: .normal)
    postMessageButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15.0)
    postMessageButton.addTarget(self, action: #selector(postMessage), for: .touchUpInside)
    postMessageButton.isEnabled = false
    postMessageButton.alpha = 0.3
    chatTextViewBG.addSubview(postMessageButton)
    postMessageButton.rightToSuperview(offset: -10.0)
    postMessageButton.centerY(to: profileImageView)
    postMessageButton.height(to: profileImageView)
    postMessageButton.width(60.0)
    self.postMessageButton = postMessageButton
    
    //chattTextView
    let chatTextView = GrowingTextView()
    chatTextView.textColor = ANIColor.dark
    chatTextView.font = UIFont.systemFont(ofSize: 15.0)
    chatTextView.placeholder = "メッセージ"
    chatTextView.showsVerticalScrollIndicator = false
    if let lineHeight = chatTextView.font?.lineHeight {
      chatTextView.minHeight = 30.0
      chatTextView.maxHeight = lineHeight * 6
    }
    chatTextView.delegate = self
    chatTextViewBG.addSubview(chatTextView)
    let insets = UIEdgeInsets(top: 2.5, left: 5.0, bottom: 2.5, right: 5.0)
    chatTextView.edgesToSuperview(excluding: .right,insets: insets)
    chatTextView.rightToLeft(of: postMessageButton, offset: -5.0)
    self.chatTextView = chatTextView
  }
  
  private func setupNotifications() {
    ANINotificationManager.receive(viewScrolled: self, selector: #selector(keyboardHide))
  }
  
  private func setProfileImage() {
    guard let currentUser = ANISessionManager.shared.currentUser,
          let profileImageUrl = currentUser.profileImageUrl,
          let profileImageView = self.profileImageView else { return }
    
    profileImageView.sd_setImage(with: URL(string: profileImageUrl), completed: nil)
  }
  
  @objc private func keyboardHide() {
    guard let chatTextView = self.chatTextView else { return }
    
    chatTextView.endEditing(true)
  }
  
  private func updateCommentContributionButton(text: String) {
    guard let postMessageButton = self.postMessageButton else { return }
    
    if text.count > 0 {
      postMessageButton.isEnabled = true
      postMessageButton.alpha = 1.0
    } else {
      postMessageButton.isEnabled = false
      postMessageButton.alpha = 0.3
    }
  }
  
  private func checkMember() {
    guard let user = self.user,
          let userId = user.uid,
          let currentUserUid = ANISessionManager.shared.currentUserUid,
          let chatGroupId = self.chatGroupId else { return }
    
    if !isHaveGroup {
      let database = Firestore.firestore()
      
      DispatchQueue.global().async {
        let memberIds = [currentUserUid: true, userId: true]
        database.collection(KEY_CHAT_GROUPS).document(chatGroupId).updateData([KEY_CHAT_MEMBER_IDS: memberIds])
      }
    }
  }
  
  //MARK: action
  @objc private func postMessage() {
    guard let chatTextView = self.chatTextView,
          let text = chatTextView.text,
          let currentuserUid = ANISessionManager.shared.currentUserUid,
          let chatGroupId = self.chatGroupId,
          let user = self.user,
          let userId = user.uid else { return }

    let date = ANIFunction.shared.getToday()
    
    var isDiffrentBeforeDate = false
    if !messages.isEmpty {
      if let beforeDate = messages[messages.count - 1].date, String(beforeDate.prefix(10)) != String(date.prefix(10)) {
        isDiffrentBeforeDate = true
      }
    } else {
      isDiffrentBeforeDate = true
    }
    
    let message = FirebaseChatMessage(userId: currentuserUid, message: text, date: date, isDiffrentBeforeDate: isDiffrentBeforeDate)
    
    checkMember()

    let database = Firestore.firestore()
    
    do {
      let message = try FirestoreEncoder().encode(message)
      
      DispatchQueue.global().async {
        database.collection(KEY_CHAT_GROUPS).document(chatGroupId).collection(KEY_CHAT_MESSAGES).addDocument(data: message)

        let value: [String: Any] = [KEY_CHAT_UPDATE_DATE: date, KEY_CHAT_LAST_MESSAGE: text, KEY_IS_HAVE_UNREAD_MESSAGE + "." + userId: true]
        database.collection(KEY_CHAT_GROUPS).document(chatGroupId).updateData(value)
      }
    } catch let error {
      DLog(error)
    }

    chatTextView.text = ""
    updateCommentContributionButton(text: chatTextView.text)
  }
}

//MARK: GrowingTextViewDelegate
extension ANIChatBar: GrowingTextViewDelegate {
  func textViewDidChange(_ textView: UITextView) {
    updateCommentContributionButton(text: textView.text)
  }
}
