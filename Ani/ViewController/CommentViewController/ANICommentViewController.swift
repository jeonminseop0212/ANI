//
//  ANICommentViewController.swift
//  Ani
//
//  Created by jeonminseop on 2018/05/21.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit

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
  
  var commentMode: CommentMode?
  
  var story: Story?
  var qna: Qna?
  
  override func viewDidLoad() {
    setup()
    passingData()
    setupNavigationProfileImage()
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
    navigationProfileImageView.dropShadow(opacity: 0.1, offset: CGSize(width: 0.0, height: 3.0))
    navigationProfileImageView.layer.cornerRadius = NAVIGATION_PROFILE_IMAGE_VIEW_HEIGHT / 2
    myNavigationBase.addSubview(navigationProfileImageView)
    navigationProfileImageView.width(NAVIGATION_PROFILE_IMAGE_VIEW_HEIGHT)
    navigationProfileImageView.height(NAVIGATION_PROFILE_IMAGE_VIEW_HEIGHT)
    navigationProfileImageView.centerInSuperview()
    self.navigationProfileImageView = navigationProfileImageView
    
    //commentView
    let commentView = ANICommentView()
    self.view.addSubview(commentView)
    commentView.topToBottom(of: myNavigationBar)
    commentView.edgesToSuperview(excluding: .top)
    self.commentView = commentView
  }
  
  private func passingData() {
    guard let commentView = self.commentView,
          let commentMode = self.commentMode else { return }
    
    switch commentMode {
    case .story:
      commentView.story = story
    case .qna:
      commentView.qna = qna
    }
    
    commentView.commentMode = commentMode
  }
  
  private func setupNavigationProfileImage() {
    guard let navigationProfileImageView = self.navigationProfileImageView,
          let commentMode = self.commentMode else { return }
    
    switch commentMode {
    case .story:
      if let story = self.story {
        navigationProfileImageView.image = story.user.profileImage
      }
    case .qna:
      if let qna = self.qna {
        navigationProfileImageView.image = qna.user.profileImage
      }
    }
  }
  
  //MARK: Action
  @objc private func back() {
    self.navigationController?.popViewController(animated: true)
  }
}
