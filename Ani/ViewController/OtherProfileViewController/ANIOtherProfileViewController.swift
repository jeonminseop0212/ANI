//
//  ANIOtherProfileViewController.swift
//  Ani
//
//  Created by jeonminseop on 2018/06/12.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import TinyConstraints
import FirebaseFirestore
import CodableFirebase
import FirebaseStorage

class ANIOtherProfileViewController: UIViewController {
  
  private weak var myNavigationBar: UIView?
  private weak var myNavigationBase: UIView?
  private weak var navigationTitleLabel: UILabel?
  private weak var backButton: UIButton?
  private weak var optionButton: UIButton?
  private weak var messageButton: UIButton?
  private let MESSAGE_RIGTHT_GRADATION_VIEW_WIDTH: CGFloat = 35.0
  private weak var messageRightGradationView: UIView?
  
  private weak var profileBasicView: ANIOtherProfileBasicView?
  
  private var rejectViewBottomConstraint: Constraint?
  private var rejectViewBottomConstraintOriginalConstant: CGFloat?
  private weak var rejectView: ANIRejectView?
  private var isRejectAnimating: Bool = false
  private var rejectTapView: UIView?
  
  private var user: FirebaseUser?
  var userId: String?
  
  private var contentType: ContentType?
  private var reportId: String?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    UIApplication.shared.statusBarStyle = .default
    setupNotification()
  }

  override func viewWillDisappear(_ animated: Bool) {
    removeNotifications()
  }
  
  private func setup() {
    //basic
    self.view.backgroundColor = .white
    
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
    
    //optionButton
    let optionButton = UIButton()
    let optionButtonImage = UIImage(named: "optionButton")?.withRenderingMode(.alwaysTemplate)
    optionButton.setImage(optionButtonImage, for: .normal)
    optionButton.tintColor = ANIColor.dark
    optionButton.addTarget(self, action: #selector(option), for: .touchUpInside)
    myNavigationBase.addSubview(optionButton)
    optionButton.width(40.0)
    optionButton.height(44.0)
    optionButton.rightToSuperview(offset: 5.0)
    optionButton.centerYToSuperview()
    self.optionButton = optionButton
    
    //messageButton
    let messageButton = UIButton()
    let messageButtonImage = UIImage(named: "messageButton")?.withRenderingMode(.alwaysTemplate)
    messageButton.setImage(messageButtonImage, for: .normal)
    messageButton.tintColor = ANIColor.dark
    messageButton.addTarget(self, action: #selector(message), for: .touchUpInside)
    myNavigationBase.addSubview(messageButton)
    messageButton.width(30.0)
    messageButton.height(44.0)
    messageButton.rightToLeft(of: optionButton)
    messageButton.centerYToSuperview()
    self.messageButton = messageButton
    
    //navigationTitleLabel
    let navigationTitleLabel = UILabel()
    navigationTitleLabel.text = "プロフィール"
    navigationTitleLabel.textColor = ANIColor.dark
    navigationTitleLabel.textAlignment = .center
    navigationTitleLabel.lineBreakMode = .byCharWrapping
    navigationTitleLabel.font = UIFont.boldSystemFont(ofSize: 17)
    myNavigationBase.addSubview(navigationTitleLabel)
    navigationTitleLabel.centerYToSuperview()
    navigationTitleLabel.leftToRight(of: backButton, offset: 35.0)
    navigationTitleLabel.rightToLeft(of: messageButton, offset: -5.0)
    self.navigationTitleLabel = navigationTitleLabel
    
    //messageRightGradationView
    let messageRightGradationView = UIView()
    let gradiationLayer = CAGradientLayer()
    gradiationLayer.startPoint = CGPoint(x: 0.8, y: 0.5)
    gradiationLayer.endPoint = CGPoint(x: 0, y: 0.5)
    gradiationLayer.frame = CGRect(x: 0, y: 0, width: MESSAGE_RIGTHT_GRADATION_VIEW_WIDTH, height: UIViewController.NAVIGATION_BAR_HEIGHT)
    gradiationLayer.colors = [UIColor.white.cgColor, UIColor.white.withAlphaComponent(0).cgColor]
    messageRightGradationView.layer.addSublayer(gradiationLayer)
    myNavigationBase.addSubview(messageRightGradationView)
    messageRightGradationView.rightToLeft(of: messageButton, offset: 0.0)
    messageRightGradationView.width(MESSAGE_RIGTHT_GRADATION_VIEW_WIDTH)
    messageRightGradationView.topToSuperview()
    messageRightGradationView.bottomToSuperview()
    self.messageRightGradationView = messageRightGradationView
    
    //profileBasicView
    let profileBasicView = ANIOtherProfileBasicView()
    profileBasicView.userId = userId
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
    
    //rejectTapView
    let rejectTapView = UIView()
    rejectTapView.isUserInteractionEnabled = true
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(rejectViewTapped))
    rejectTapView.addGestureRecognizer(tapGesture)
    rejectTapView.isHidden = true
    rejectTapView.backgroundColor = .clear
    self.view.addSubview(rejectTapView)
    rejectTapView.size(to: rejectView)
    rejectTapView.topToSuperview()
    self.rejectTapView = rejectTapView
  }
  
  //MARK: notification
  private func setupNotification() {
    ANINotificationManager.receive(imageCellTapped: self, selector: #selector(presentImageBrowser(_:)))
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
    imageBrowserViewController.delegate = self
    //overCurrentContextだとtabBarが消えないのでtabBarからpresentする
    self.tabBarController?.present(imageBrowserViewController, animated: false, completion: nil)
  }
  
  //MARK: action
  @objc private func back() {
    self.navigationController?.popViewController(animated: true)
  }
  
  @objc private func rejectViewTapped() {
    let initialViewController = ANIInitialViewController()
    let navigationController = UINavigationController(rootViewController: initialViewController)
    self.present(navigationController, animated: true, completion: nil)
  }
  
  @objc private func option() {
    self.contentType = .user
    self.reportId = userId
    
    let popupOptionViewController = ANIPopupOptionViewController()
    popupOptionViewController.modalPresentationStyle = .overCurrentContext
    popupOptionViewController.isMe = false
    popupOptionViewController.delegate = self
    self.tabBarController?.present(popupOptionViewController, animated: false, completion: nil)
  }
  
  @objc private func message() {
    if !ANISessionManager.shared.isAnonymous {
      let chatViewController = ANIChatViewController()
      let navigationContoller = UINavigationController(rootViewController: chatViewController)
      chatViewController.user = user
      chatViewController.isPush = false
      self.present(navigationContoller, animated: true, completion: nil)
    } else {
      reject()
    }
  }
}

//MARK: ANIProfileBasicViewDelegate
extension ANIOtherProfileViewController: ANIOtherProfileBasicViewDelegate {
  func loadedUser(user: FirebaseUser) {
    guard let navigationTitleLabel = self.navigationTitleLabel,
          let userName = user.userName else { return }
    
    self.user = user
    navigationTitleLabel.text = userName
  }
  
  func followingTapped() {
    guard let userId = self.userId else { return }
    
    let followUserViewController = ANIFollowUserViewContoller()
    followUserViewController.followUserViewMode = .following
    followUserViewController.userId = userId
    followUserViewController.hidesBottomBarWhenPushed = true
    self.navigationController?.pushViewController(followUserViewController, animated: true)
  }
  
  func followerTapped() {
    guard let userId = self.userId else { return }
    
    let followUserViewController = ANIFollowUserViewContoller()
    followUserViewController.followUserViewMode = .follower
    followUserViewController.userId = userId
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
          !isRejectAnimating,
          let rejectTapView = self.rejectTapView else { return }
    
    rejectViewBottomConstraint.constant = UIViewController.NAVIGATION_BAR_HEIGHT + UIViewController.STATUS_BAR_HEIGHT
    rejectTapView.isHidden = false

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
        rejectTapView.isHidden = true
      })
    }
  }
  
  func popupOptionView(isMe: Bool, contentType: ContentType, id: String) {
    self.contentType = contentType
    self.reportId = id
    
    let popupOptionViewController = ANIPopupOptionViewController()
    popupOptionViewController.modalPresentationStyle = .overCurrentContext
    popupOptionViewController.isMe = isMe
    popupOptionViewController.delegate = self
    self.tabBarController?.present(popupOptionViewController, animated: false, completion: nil)
  }
}

//MARK: ANIImageBrowserViewControllerDelegate
extension ANIOtherProfileViewController: ANIImageBrowserViewControllerDelegate {
  func imageBrowserDidDissmiss() {
    UIApplication.shared.statusBarStyle = .default
  }
}

//MARK: ANIPopupOptionViewControllerDelegate
extension ANIOtherProfileViewController: ANIPopupOptionViewControllerDelegate {
  func deleteContribution() {
  }
  
  func reportContribution() {
    guard let contentType = self.contentType else { return }
    
    var message = ""
    if contentType == .user {
      message = "ユーザーを通報しますか？"
    } else {
      message = "投稿を通報しますか？"
    }
    
    let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
    
    let reportAction = UIAlertAction(title: "通報", style: .default) { (action) in
      self.reportData()
    }
    let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel)
    
    alertController.addAction(reportAction)
    alertController.addAction(cancelAction)
    
    self.present(alertController, animated: true, completion: nil)
  }
  
  func optionTapped(index: Int) {
  }
}

//MAKR: data
extension ANIOtherProfileViewController {
  private func reportData() {
    guard let contentType = self.contentType, let reportId = self.reportId else { return }
    
    let database = Firestore.firestore()
    
    var contentTypeString = ""
    
    if contentType == .recruit {
      contentTypeString = "recurit"
    } else if contentType == .story {
      contentTypeString = "story"
    } else if contentType == .qna {
      contentTypeString = "qna"
    } else if contentType == .user {
      contentTypeString = "user"
    }
    
    let date = ANIFunction.shared.getToday()
    let values = ["contentType": contentTypeString, "date": date]
    database.collection(KEY_REPORTS).document(reportId).collection(KEY_REPORT).addDocument(data: values)
  }
}
