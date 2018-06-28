//
//  ChatBar.swift
//  Ani
//
//  Created by jeonminseop on 2018/06/28.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import GrowingTextView
import FirebaseDatabase
import CodableFirebase

class ANIChatBar: UIView {
  
  private weak var profileImageView: UIImageView?
  
  private weak var chatTextViewBG: UIView?
  private weak var chatTextView: GrowingTextView?
  
  private weak var chatContributionButton: UIButton?
  
  var chatGroupId: String?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setup()
    setProfileImage()
    setupNotification()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    //profileImageView
    let profileImageView = UIImageView()
    profileImageView.backgroundColor = ANIColor.bg
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
    let bgInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: -10.0)
    chatTextViewBG.leftToRight(of: profileImageView, offset: 10.0)
    chatTextViewBG.edgesToSuperview(excluding: .left, insets: bgInsets)
    self.chatTextViewBG = chatTextViewBG
    
    //chatContributionButton
    let chatContributionButton = UIButton()
    chatContributionButton.setTitle("送信する", for: .normal)
    chatContributionButton.setTitleColor(ANIColor.green, for: .normal)
    chatContributionButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15.0)
    chatContributionButton.addTarget(self, action: #selector(contribute), for: .touchUpInside)
    chatContributionButton.isEnabled = false
    chatContributionButton.alpha = 0.3
    chatTextViewBG.addSubview(chatContributionButton)
    chatContributionButton.rightToSuperview(offset: 10.0)
    chatContributionButton.centerY(to: profileImageView)
    chatContributionButton.height(to: profileImageView)
    chatContributionButton.width(60.0)
    self.chatContributionButton = chatContributionButton
    
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
    let insets = UIEdgeInsets(top: 2.5, left: 5.0, bottom: 2.5, right: -5.0)
    chatTextView.edgesToSuperview(excluding: .right,insets: insets)
    chatTextView.rightToLeft(of: chatContributionButton, offset: -5.0)
    self.chatTextView = chatTextView
  }
  
  private func setupNotification() {
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
    guard let chatContributionButton = self.chatContributionButton else { return }
    
    if text.count > 0 {
      chatContributionButton.isEnabled = true
      chatContributionButton.alpha = 1.0
    } else {
      chatContributionButton.isEnabled = false
      chatContributionButton.alpha = 0.3
    }
  }
  
  //MARK: action
  @objc private func contribute() {
    guard let chatTextView = self.chatTextView,
          let text = chatTextView.text,
          let currentuserUid = ANISessionManager.shared.currentUserUid,
          let chatGroupId = self.chatGroupId else { return }

    let date = ANIFunction.shared.getToday()
    let message = FirebaseChatMessage(userId: currentuserUid, message: text, date: date)

    do {
      if let data = try FirebaseEncoder().encode(message) as? [String : AnyObject] {
        let detabaseRef = Database.database().reference()

        DispatchQueue.global().async {
          let databaseMessageRef = detabaseRef.child(KEY_CHAT_MESSAGES).child(chatGroupId).childByAutoId()
          databaseMessageRef.updateChildValues(data)

          let detabaseGroupRef = detabaseRef.child(KEY_CHAT_GROUPS).child(chatGroupId)
          let value: [String: String] = [KEY_CHAT_UPDATE_DATE: date, KEY_CHAT_LAST_MESSAGE: text]
          detabaseGroupRef.updateChildValues(value)
        }
      }
    } catch let error {
      print(error)
    }

    chatTextView.text = ""
    chatTextView.endEditing(true)
    updateCommentContributionButton(text: chatTextView.text)
  }
}

//MARK: GrowingTextViewDelegate
extension ANIChatBar: GrowingTextViewDelegate {
  func textViewDidChange(_ textView: UITextView) {
    updateCommentContributionButton(text: textView.text)
  }
}
