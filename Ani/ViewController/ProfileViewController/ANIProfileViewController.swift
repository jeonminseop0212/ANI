//
//  ANIProfileViewController.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/17.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import TinyConstraints

class ANIProfileViewController: UIViewController {
  
  private weak var myNavigationBar: UIView?
  private weak var myNavigationBase: UIView?
  private weak var navigationTitleLabel: UILabel?
  private weak var backButton: UIButton?
  private weak var optionButton: UIButton?
  
  private weak var needLoginView: ANINeedLoginView?
  
  var isBackButtonHide: Bool = true
  
  private weak var profileBasicView: ANIProfileBasicView?
  
  private var rejectViewBottomConstraint: Constraint?
  private var rejectViewBottomConstraintOriginalConstant: CGFloat?
  private weak var rejectView: ANIRejectView?
  private var isRejectAnimating: Bool = false
  
  private var currentUser: FirebaseUser? { return ANISessionManager.shared.currentUser }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    UIApplication.shared.statusBarStyle = .default
    setupNotification()
    showNeedLoginView()
  }

  override func viewWillDisappear(_ animated: Bool) {
    removeNotifications()
  }
  
  private func setup() {
    //basic
    self.view.backgroundColor = .white
    self.navigationController?.setNavigationBarHidden(true, animated: false)
    self.navigationController?.navigationBar.isTranslucent = false
    ANIOrientation.lockOrientation(.portrait)
    
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
    
    //navigationTitleLabel
    let navigationTitleLabel = UILabel()
    navigationTitleLabel.text = "プロフィール"
    navigationTitleLabel.textColor = ANIColor.dark
    navigationTitleLabel.font = UIFont.boldSystemFont(ofSize: 17)
    myNavigationBase.addSubview(navigationTitleLabel)
    navigationTitleLabel.centerInSuperview()
    self.navigationTitleLabel = navigationTitleLabel
    
    //backButton
    let backButton = UIButton()
    let backButtonImage = UIImage(named: "backButton")?.withRenderingMode(.alwaysTemplate)
    backButton.setImage(backButtonImage, for: .normal)
    backButton.tintColor = ANIColor.dark
    backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
    if isBackButtonHide {
      backButton.alpha = 0.0
    } else {
      backButton.alpha = 1.0
    }
    myNavigationBase.addSubview(backButton)
    backButton.width(44.0)
    backButton.height(44.0)
    backButton.leftToSuperview()
    backButton.centerYToSuperview()
    self.backButton = backButton
    
    //optionButton
    let optionButton = UIButton()
    let optionButtonImage = UIImage(named: "optionButton")?.withRenderingMode(.alwaysTemplate)
    optionButton.setImage(optionButtonImage, for: .normal)
    optionButton.tintColor = ANIColor.dark
    optionButton.addTarget(self, action: #selector(option), for: .touchUpInside)
    myNavigationBase.addSubview(optionButton)
    optionButton.width(50.0)
    optionButton.height(44.0)
    optionButton.rightToSuperview()
    optionButton.centerYToSuperview()
    self.optionButton = optionButton
    
    //profileBasicView
    let profileBasicView = ANIProfileBasicView()
    profileBasicView.currentUser = currentUser
    profileBasicView.delegate = self
    self.view.addSubview(profileBasicView)
    profileBasicView.topToBottom(of: myNavigationBar)
    profileBasicView.edgesToSuperview(excluding: .top)
    self.profileBasicView = profileBasicView
    
    //rejectView
    let rejectView = ANIRejectView()
    rejectView.setRejectText("ログインが必要です。")
    self.view.addSubview(rejectView)
    rejectViewBottomConstraint = rejectView.bottomToTop(of: self.view)
    rejectViewBottomConstraintOriginalConstant = rejectViewBottomConstraint?.constant
    rejectView.leftToSuperview()
    rejectView.rightToSuperview()
    self.rejectView = rejectView
    
    //needLoginView
    let needLoginView = ANINeedLoginView()
    needLoginView.isHidden = true
    needLoginView.setupMessage(text: "プロフィールを利用するには\nログインが必要です。")
    needLoginView.delegate = self
    self.view.addSubview(needLoginView)
    needLoginView.edgesToSuperview()
    self.needLoginView = needLoginView
  }
  
  private func showNeedLoginView() {
    guard let needLoginView = self.needLoginView else { return }
    
    if ANISessionManager.shared.isAnonymous == true {
      needLoginView.isHidden = false
    } else {
      needLoginView.isHidden = true
    }
  }
  
  //MAKR: notification
  private func setupNotification() {
    ANINotificationManager.receive(imageCellTapped: self, selector: #selector(presentImageBrowser(_:)))
    ANINotificationManager.receive(profileEditButtonTapped: self, selector: #selector(openProfileEdit))
  }
  
  private func removeNotifications() {
    ANINotificationManager.remove(self)
  }
  
  @objc private func presentImageBrowser(_ notification: NSNotification) {
    guard let item = notification.object as? (Int, [String]) else { return }
    let selectedIndex = item.0
    let imageUrls = item.1
    let imageBrowserViewController = ANIImageBrowserViewController()
    imageBrowserViewController.selectedIndex = selectedIndex
    imageBrowserViewController.imageUrls = imageUrls
    imageBrowserViewController.modalPresentationStyle = .overCurrentContext
    //overCurrentContextだとtabBarが消えないのでtabBarからpresentする
    self.tabBarController?.present(imageBrowserViewController, animated: false, completion: nil)
  }
  
  @objc private func openProfileEdit() {
    let profileEditViewController = ANIProfileEditViewController()
    profileEditViewController.delegate = self
    profileEditViewController.currentUser = currentUser
    self.present(profileEditViewController, animated: true, completion: nil)
  }
  
  //MARK: action
  @objc private func back() {
    self.navigationController?.popViewController(animated: true)
  }
  
  @objc private func option() {
    let optionViewController = ANIOptionViewController()
    optionViewController.hidesBottomBarWhenPushed = true
    self.navigationController?.pushViewController(optionViewController, animated: true)
  }
}

//MARK: ANIProfileBasicViewDelegate
extension ANIProfileViewController: ANIProfileBasicViewDelegate {
  func followingTapped() {
    guard let currentUser = self.currentUser else { return }
    
    let followUserViewController = ANIFollowUserViewContoller()
    followUserViewController.followUserViewMode = .following
    followUserViewController.userId = currentUser.uid
    followUserViewController.hidesBottomBarWhenPushed = true
    self.navigationController?.pushViewController(followUserViewController, animated: true)
  }
  
  func followerTapped() {
    guard let currentUser = self.currentUser else { return }

    let followUserViewController = ANIFollowUserViewContoller()
    followUserViewController.followUserViewMode = .follower
    followUserViewController.userId = currentUser.uid
    followUserViewController.hidesBottomBarWhenPushed = true
    self.navigationController?.pushViewController(followUserViewController, animated: true)
  }
  
  func supportButtonTapped(supportRecruit: FirebaseRecruit, user: FirebaseUser) {
    let supportViewController = ANISupportViewController()
    supportViewController.modalPresentationStyle = .overCurrentContext
    supportViewController.recruit = supportRecruit
    supportViewController.user = user
    self.tabBarController?.present(supportViewController, animated: false, completion: nil)
  }
  
  func recruitViewCellDidSelect(selectedRecruit: FirebaseRecruit, user: FirebaseUser) {
    let recruitDetailViewController = ANIRecruitDetailViewController()
    recruitDetailViewController.hidesBottomBarWhenPushed = true
    recruitDetailViewController.recruit = selectedRecruit
    recruitDetailViewController.user = user
    self.navigationController?.pushViewController(recruitDetailViewController, animated: true)
  }
  
  func storyViewCellDidSelect(selectedStory: FirebaseStory, user: FirebaseUser) {
    let commentViewController = ANICommentViewController()
    commentViewController.hidesBottomBarWhenPushed = true
    commentViewController.commentMode = CommentMode.story
    commentViewController.story = selectedStory
    commentViewController.user = user
    self.navigationController?.pushViewController(commentViewController, animated: true)
  }
  
  func supportCellRecruitTapped(recruit: FirebaseRecruit, user: FirebaseUser) {
    let recruitDetailViewController = ANIRecruitDetailViewController()
    recruitDetailViewController.hidesBottomBarWhenPushed = true
    recruitDetailViewController.recruit = recruit
    recruitDetailViewController.user = user
    self.navigationController?.pushViewController(recruitDetailViewController, animated: true)
  }
  
  func qnaViewCellDidSelect(selectedQna: FirebaseQna, user: FirebaseUser) {
    let commentViewController = ANICommentViewController()
    commentViewController.hidesBottomBarWhenPushed = true
    commentViewController.commentMode = CommentMode.qna
    commentViewController.qna = selectedQna
    commentViewController.user = user
    self.navigationController?.pushViewController(commentViewController, animated: true)
  }
  
  func reject() {
    guard let rejectViewBottomConstraint = self.rejectViewBottomConstraint,
          !isRejectAnimating else { return }
    
    rejectViewBottomConstraint.constant = UIViewController.NAVIGATION_BAR_HEIGHT + UIViewController.STATUS_BAR_HEIGHT
    UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: {
      self.isRejectAnimating = true
      self.view.layoutIfNeeded()
    }) { (complete) in
      guard let rejectViewBottomConstraint = self.rejectViewBottomConstraint,
        let rejectViewBottomConstraintOriginalConstant = self.rejectViewBottomConstraintOriginalConstant else { return }
      
      rejectViewBottomConstraint.constant = rejectViewBottomConstraintOriginalConstant
      UIView.animate(withDuration: 0.3, delay: 1.0, options: .curveEaseInOut, animations: {
        self.view.layoutIfNeeded()
      }, completion: { (complete) in
        self.isRejectAnimating = false
      })
    }
  }
}

//MARK: ANIProfileEditViewControllerDelegate
extension ANIProfileViewController: ANIProfileEditViewControllerDelegate {
  func didEdit() {
    guard let profileBasicView = self.profileBasicView else { return }
    profileBasicView.currentUser = currentUser
  }
}

//MARK: ANINeedLoginViewDelegate
extension ANIProfileViewController: ANINeedLoginViewDelegate {
  func loginButtonTapped() {
    let initialViewController = ANIInitialViewController()
    let navigationController = UINavigationController(rootViewController: initialViewController)
    self.present(navigationController, animated: true, completion: nil)
  }
}
