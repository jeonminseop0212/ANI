//
//  CommentBar.swift
//  Ani
//
//  Created by jeonminseop on 2018/05/22.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import GrowingTextView
import FirebaseFirestore
import CodableFirebase

class ANICommentBar: UIView {
  
  private weak var profileImageView: UIImageView?
  
  private weak var commentTextViewBG: UIView?
  private weak var commentTextView: GrowingTextView?
  
  private weak var commentContributionButton: UIButton?
  
  var commentMode: CommentMode?

  var story: FirebaseStory?
  var qna: FirebaseQna?
    
  var user: FirebaseUser?
  
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
    
    //commentTextViewBG
    let commentTextViewBG = UIView()
    commentTextViewBG.layer.cornerRadius = profileImageView.layer.cornerRadius
    commentTextViewBG.layer.masksToBounds = true
    commentTextViewBG.layer.borderColor = ANIColor.gray.cgColor
    commentTextViewBG.layer.borderWidth = 1.0
    addSubview(commentTextViewBG)
    let bgInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
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
    commentContributionButton.rightToSuperview(offset: -10.0)
    commentContributionButton.centerY(to: profileImageView)
    commentContributionButton.height(to: profileImageView)
    commentContributionButton.width(60.0)
    self.commentContributionButton = commentContributionButton
    
    //commentTextView
    let commentTextView = GrowingTextView()
    commentTextView.textColor = ANIColor.dark
    commentTextView.font = UIFont.systemFont(ofSize: 15.0)
    commentTextView.placeholder = "コメント"
    commentTextView.showsVerticalScrollIndicator = false
    if let lineHeight = commentTextView.font?.lineHeight {
      commentTextView.minHeight = 30.0
      commentTextView.maxHeight = lineHeight * 6
    }
    commentTextView.delegate = self
    commentTextViewBG.addSubview(commentTextView)
    let insets = UIEdgeInsets(top: 2.5, left: 5.0, bottom: 2.5, right: 5.0)
    commentTextView.edgesToSuperview(excluding: .right,insets: insets)
    commentTextView.rightToLeft(of: commentContributionButton, offset: -5.0)
    self.commentTextView = commentTextView
  }
  
  private func setupNotification() {
    ANINotificationManager.receive(viewScrolled: self, selector: #selector(keyboardHide))
  }
  
  func setProfileImage() {
    guard let profileImageView = self.profileImageView else { return }
    
    if let currentUser = ANISessionManager.shared.currentUser, let profileImageUrl = currentUser.profileImageUrl {
      profileImageView.sd_setImage(with: URL(string: profileImageUrl), completed: nil)
    } else {
      profileImageView.image = UIImage()
    }
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
  
  private func updateNoti(commentId: String, comment: String) {
    guard let currentUser = ANISessionManager.shared.currentUser,
          let currentUserName = currentUser.userName,
          let currentUserId = ANISessionManager.shared.currentUserUid,
          let user = self.user,
          let userId = user.uid,
          let commentMode = self.commentMode,
          currentUserId != userId else { return }
    
    let database = Firestore.firestore()
    
    DispatchQueue.global().async {
      do {
        var noti = ""
        var contributionKind = ""
        var notiId = ""
        if commentMode == .story {
          guard let story = self.story,
                let storyId = story.id else { return }
          
          noti = "\(currentUserName)さんが「\(story.story)」ストーリーにコメントしました。\n\"\(comment)\""
          contributionKind = KEY_CONTRIBUTION_KIND_STROY
          notiId = storyId
        } else if commentMode == .qna {
          guard let qna = self.qna,
                let qnaId = qna.id else { return }
          
          noti = "\(currentUserName)さんが「\(qna.qna)」質問にコメントしました。\n\"\(comment)\""
          contributionKind = KEY_CONTRIBUTION_KIND_QNA
          notiId = qnaId
        }
        
        let date = ANIFunction.shared.getToday()
        let notification = FirebaseNotification(userId: currentUserId, noti: noti, contributionKind: contributionKind, notiKind: KEY_NOTI_KIND_COMMENT, notiId: notiId, commentId: commentId, updateDate: date)
        let id = NSUUID().uuidString
        let data = try FirestoreEncoder().encode(notification)
        
        database.collection(KEY_USERS).document(userId).collection(KEY_NOTIFICATIONS).document(id).setData(data)
      } catch let error {
        DLog(error)
      }
    }
  }
  
  //MARK: action
  @objc private func contribute() {
    guard let commentTextView = self.commentTextView,
          let text = commentTextView.text,
          let currentuser = ANISessionManager.shared.currentUser,
          let uid = currentuser.uid,
          let commentMode = self.commentMode else { return }
    
    let date = ANIFunction.shared.getToday()
    let comment = FirebaseComment(userId: uid, comment: text, date: date)
    
    do {
      if let data = try FirebaseEncoder().encode(comment) as? [String : AnyObject] {
        let database = Firestore.firestore()
        
        switch commentMode {
        case .story:
          guard let story = self.story,
                let storyId = story.id else { return }
          
          DispatchQueue.global().async {
            let id = NSUUID().uuidString
            database.collection(KEY_STORIES).document(storyId).collection(KEY_COMMENTS).document(id).setData(data)

            self.updateNoti(commentId: id, comment: comment.comment)
          }
        case .qna:
          guard let qna = self.qna,
                let qnaId = qna.id else { return }
          
          DispatchQueue.global().async {
            let id = NSUUID().uuidString
            database.collection(KEY_QNAS).document(qnaId).collection(KEY_COMMENTS).document(id).setData(data)

            self.updateNoti(commentId: id, comment: comment.comment)
          }
        }
      }
    } catch let error {
      DLog(error)
    }
    
    commentTextView.text = ""
    commentTextView.endEditing(true)
    updateCommentContributionButton(text: commentTextView.text)
  }
}

//MARK: GrowingTextViewDelegate
extension ANICommentBar: GrowingTextViewDelegate {
  func textViewDidChange(_ textView: UITextView) {
    updateCommentContributionButton(text: textView.text)
  }
}
