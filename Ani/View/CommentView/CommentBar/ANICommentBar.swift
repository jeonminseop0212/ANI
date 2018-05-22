//
//  CommentBar.swift
//  Ani
//
//  Created by jeonminseop on 2018/05/22.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

class ANICommentBar: UIView {
  
  private weak var profileImageView: UIImageView?
  
  private weak var commentTextViewBG: UIView?
  private weak var commentTextView: ANIPlaceHolderTextView?
  
  private weak var commentContributionButton: UIButton?
  
  var me: User? {
    didSet {
      guard let profileImageView = self.profileImageView,
            let me = self.me else { return }
      
      profileImageView.image = me.profileImage
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setup()
    setupNotification()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    //profileImageView
    let profileImageView = UIImageView()
    profileImageView.layer.cornerRadius = 40.0 / 2
    profileImageView.layer.masksToBounds = true
    addSubview(profileImageView)
    profileImageView.width(40.0)
    profileImageView.height(40.0)
    profileImageView.bottomToSuperview(offset: -10.0)
    profileImageView.leftToSuperview(offset: 10.0)
    self.profileImageView = profileImageView
    
    //commentTextViewBG
    let commentTextViewBG = UIView()
    commentTextViewBG.layer.cornerRadius = profileImageView.layer.cornerRadius
    commentTextViewBG.layer.masksToBounds = true
    commentTextViewBG.layer.borderColor = ANIColor.gray.cgColor
    commentTextViewBG.layer.borderWidth = 1.0
    addSubview(commentTextViewBG)
    let bgInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: -10.0)
    commentTextViewBG.leftToRight(of: profileImageView, offset: 10.0)
    commentTextViewBG.edgesToSuperview(excluding: .left, insets: bgInsets)
    self.commentTextViewBG = commentTextViewBG
    
    //commentContributionButton
    let commentContributionButton = UIButton()
    commentContributionButton.setTitle("投稿する", for: .normal)
    commentContributionButton.setTitleColor(ANIColor.green, for: .normal)
    commentContributionButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15.0)
    commentContributionButton.addTarget(self, action: #selector(contribute), for: .touchUpInside)
    commentContributionButton.isEnabled = false
    commentContributionButton.alpha = 0.3
    commentTextViewBG.addSubview(commentContributionButton)
    commentContributionButton.rightToSuperview(offset: 10.0)
    commentContributionButton.centerY(to: profileImageView, offset: -2.0)
    commentContributionButton.height(to: profileImageView)
    commentContributionButton.width(60.0)
    self.commentContributionButton = commentContributionButton
    
    //commentTextView
    let commentTextView = ANIPlaceHolderTextView()
    commentTextView.textColor = ANIColor.dark
    commentTextView.font = UIFont.systemFont(ofSize: 15.0)
    commentTextView.placeHolder = "コメント"
    commentTextView.isScrollEnabled = false
    commentTextView.delegate = self
    commentTextViewBG.addSubview(commentTextView)
    let insets = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: -5.0)
    commentTextView.edgesToSuperview(excluding: .right, insets: insets)
    commentTextView.rightToLeft(of: commentContributionButton, offset: -10.0)
    self.commentTextView = commentTextView
  }
  
  private func setupNotification() {
    ANINotificationManager.receive(viewScrolled: self, selector: #selector(keyboardHide))
  }
  
  @objc private func keyboardHide() {
    guard let commentTextView = self.commentTextView else { return }
    commentTextView.endEditing(true)
  }
  
  private func updateCommentContributionButton(text: String) {
    guard let commentContributionButton = self.commentContributionButton else { return }
    
    if text.count > 0 {
      commentContributionButton.isEnabled = true
      commentContributionButton.alpha = 1.0
    } else {
      commentContributionButton.isEnabled = false
      commentContributionButton.alpha = 0.3
    }
  }
  
  //MARK: action
  @objc private func contribute() {
    guard let commentTextView = self.commentTextView else { return }
    commentTextView.text = ""
    commentTextView.placeHolderLabel.alpha = 1.0
    commentTextView.endEditing(true)
    updateCommentContributionButton(text: commentTextView.text)
  }
}

//MARK: UITextViewDelegate
extension ANICommentBar: UITextViewDelegate {
  func textViewDidChange(_ textView: UITextView) {
    updateCommentContributionButton(text: textView.text)
  }
}
