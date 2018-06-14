//
//  ANICommentViewController.swift
//  Ani
//
//  Created by jeonminseop on 2018/05/21.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import TinyConstraints

enum CommentMode {
  case story
  case qna
}

class ANICommentViewController: UIViewController {
  
  private weak var myNavigationBar: UIView?
  private weak var myNavigationBase: UIView?
  private weak var backButton: UIButton?
  private let NAVIGATION_PROFILE_IMAGE_VIEW_HEIGHT: CGFloat = 30.0
  private weak var navigationProfileImageView: UIImageView?
  
  private weak var commentView: ANICommentView?
  
  private var commentBarBottomConstraint: Constraint?
  private var commentBarOriginalBottomConstraintConstant: CGFloat?
  private weak var commentBar: ANICommentBar?
    
  var commentMode: CommentMode?
  
  var story: FirebaseStory?
  var qna: FirebaseQna?
  var user: FirebaseUser?
  
  override func viewDidLoad() {
    setup()
    passingData()
    setupNavigationProfileImage()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    setupNotification()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    removeNotifications()
  }
  
  private func setup() {
    //basic
    self.view.backgroundColor = .white
    self.navigationController?.navigationBar.tintColor = .white
    self.navigationController?.setNavigationBarHidden(true, animated: false)
    self.navigationController?.navigationBar.isTranslucent = false
    
    //myNavigationBar
    let myNavigationBar = UIView()
    myNavigationBar.backgroundColor = .white
    self.view.addSubview(myNavigationBar)
    myNavigationBar.topToSuperview()
    myNavigationBar.leftToSuperview()
    myNavigationBar.rightToSuperview()
    myNavigationBar.height(UIViewController.STATUS_BAR_HEIGHT + UIViewController.NAVIGATION_BAR_HEIGHT)
    self.myNavigationBar = myNavigationBar
    
    //myNavigationBase
    let myNavigationBase = UIView()
    myNavigationBar.addSubview(myNavigationBase)
    myNavigationBase.edgesToSuperview(excluding: .top)
    myNavigationBase.height(UIViewController.NAVIGATION_BAR_HEIGHT)
    self.myNavigationBase = myNavigationBase
    
    //backButton
    let backButton = UIButton()
    let backButtonImage = UIImage(named: "backButton")?.withRenderingMode(.alwaysTemplate)
    backButton.setImage(backButtonImage, for: .normal)
    backButton.tintColor = ANIColor.dark
    backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
    myNavigationBase.addSubview(backButton)
    backButton.width(44.0)
    backButton.height(44.0)
    backButton.leftToSuperview()
    backButton.centerYToSuperview()
    self.backButton = backButton
    
    //navigationProfileImageView
    let navigationProfileImageView = UIImageView()
    navigationProfileImageView.contentMode = .scaleAspectFit
//    navigationProfileImageView.dropShadow(opacity: 0.1, offset: CGSize(width: 0.0, height: 3.0))
    navigationProfileImageView.layer.cornerRadius = NAVIGATION_PROFILE_IMAGE_VIEW_HEIGHT / 2
    navigationProfileImageView.layer.masksToBounds = true
    myNavigationBase.addSubview(navigationProfileImageView)
    navigationProfileImageView.width(NAVIGATION_PROFILE_IMAGE_VIEW_HEIGHT)
    navigationProfileImageView.height(NAVIGATION_PROFILE_IMAGE_VIEW_HEIGHT)
    navigationProfileImageView.centerInSuperview()
    self.navigationProfileImageView = navigationProfileImageView
    
    //commentBar
    let commentBar = ANICommentBar()
    self.view.addSubview(commentBar)
    commentBar.leftToSuperview()
    commentBar.rightToSuperview()
    commentBarBottomConstraint = commentBar.bottomToSuperview(usingSafeArea: true)
    commentBarOriginalBottomConstraintConstant = commentBarBottomConstraint?.constant
    self.commentBar = commentBar
    
    //commentView
    let commentView = ANICommentView()
    self.view.addSubview(commentView)
    commentView.topToBottom(of: myNavigationBar)
    commentView.leftToSuperview()
    commentView.rightToSuperview()
    commentView.bottomToTop(of: commentBar)
    self.commentView = commentView
  }
  
  private func passingData() {
    guard let commentView = self.commentView,
          let commentBar = self.commentBar,
          let commentMode = self.commentMode else { return }

    commentView.commentMode = commentMode
    commentBar.commentMode = commentMode
    
    switch commentMode {
    case .story:
      commentView.story = story
      commentBar.story = story
    case .qna:
      commentView.qna = qna
      commentBar.qna = qna
    }
  }
  
  private func setupNavigationProfileImage() {
    guard let navigationProfileImageView = self.navigationProfileImageView,
          let user = self.user,
          let profileImageUrl = user.profileImageUrl else { return }
    
    navigationProfileImageView.sd_setImage(with: URL(string: profileImageUrl), completed: nil)
  }
  
  //MARK: notification
  private func setupNotification() {
    ANINotificationManager.receive(keyboardWillChangeFrame: self, selector: #selector(keyboardWillChangeFrame))
    ANINotificationManager.receive(keyboardWillHide: self, selector: #selector(keyboardWillHide))
    ANINotificationManager.receive(profileImageViewTapped: self, selector: #selector(pushOtherProfile))
  }
  
  private func removeNotifications() {
    ANINotificationManager.remove(self)
  }
  
  @objc private func keyboardWillChangeFrame(_ notification: Notification) {
    guard let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
      let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval,
      let curve = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? UInt,
      let commentBarBottomConstraint = self.commentBarBottomConstraint,
      let window = UIApplication.shared.keyWindow else { return }
    
    let h = keyboardFrame.height
    let bottomSafeArea = window.safeAreaInsets.bottom
    
    commentBarBottomConstraint.constant = -h + bottomSafeArea
    
    UIView.animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions(rawValue: curve), animations: {
      self.view.layoutIfNeeded()
    })
  }
  
  @objc private func keyboardWillHide(_ notification: Notification) {
    guard let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval,
      let curve = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? UInt,
      let commentBarOriginalBottomConstraintConstant = self.commentBarOriginalBottomConstraintConstant,
      let commentBarBottomConstraint = self.commentBarBottomConstraint else { return }
    
    commentBarBottomConstraint.constant = commentBarOriginalBottomConstraintConstant
    
    UIView.animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions(rawValue: curve), animations: {
      self.view.layoutIfNeeded()
    })
  }
  
  @objc private func pushOtherProfile(_ notification: NSNotification) {
    guard let userId = notification.object as? String,
          let currentUserUid = ANISessionManager.shared.currentUserUid else { return }
    
    if currentUserUid == userId {
      let profileViewController = ANIProfileViewController()
      profileViewController.hidesBottomBarWhenPushed = true
      self.navigationController?.pushViewController(profileViewController, animated: true)
      profileViewController.isBackButtonHide = false
    } else {
      let otherProfileViewController = ANIOtherProfileViewController()
      otherProfileViewController.hidesBottomBarWhenPushed = true
      otherProfileViewController.userId = userId
      self.navigationController?.pushViewController(otherProfileViewController, animated: true)
    }
  }
  
  //MARK: Action
  @objc private func back() {
    self.navigationController?.popViewController(animated: true)
  }
}
